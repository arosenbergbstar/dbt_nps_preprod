{#
    Extracts pipeline results and QC metrics from v2 pipeline JSON (multicancer, pancv2).

    v2 pipelines store results in a nested JSON structure (outputs.qc_metrics).
    This model extracts metrics to individual columns and applies FIO (For Information Only)
    overrides per DO-275 and CFP-2. See stg_clinpipe__results_json_v1 for the v1 equivalent.

    Pipeline list defined in dbt_project.yml var: clinpipe_v2_pipelines
    FIO cutoff uses lv__u_job.created_at (LabVantage job creation timestamp), consistent
    with fact_lv__jobs.created_at used across the analytics layer. Falls back to
    modified_at for the ~0.6% of records absent from lv__u_job (pre-existing data gap).
    FIO effective dates defined in dbt_project.yml vars: fio1_effective_date,
    fio2_effective_date.

    Performance: incremental on modified_at (full refresh on first run; subsequent runs
    process only new records). FIO overrides applied in a single nested object_insert
    expression instead of 8 chained CTEs, reducing compilation complexity.
#}
{{
    config(
        materialized="incremental",
        unique_key="hash_id",
        on_schema_change="sync_all_columns",
    )
}}

with
    src as (select * from {{ ref("stg_clinpipe__versioned_results") }}),

    -- Explicit enumeration of v2 pipelines
    filtered_src as (
        select *
        from src
        where
            pipeline_name in ('{{ var("clinpipe_v2_pipelines") | join("', '") }}')
            {% if is_incremental() %}
                -- Only process records newer than the latest already in the table
                and modified_at > (
                    select coalesce(max(modified_at), '1900-01-01'::timestamp_tz)
                    from {{ this }}
                )
            {% endif %}
    ),

    transformed_src as (
        select
            {{ rename_clia_pipeline("item_data", "job_id") }},
            {{ rename_clia_pipeline("item_data", "dna_id") }},
            {{ rename_clia_pipeline("item_data", "trf_id") }},
            {{ rename_clia_pipeline("item_data", "clia_env_version") }},
            {{ rename_clia_pipeline("item_data", "env_version") }},
            {{ rename_clia_pipeline("item_data", "b2f_version") }},
            {{ rename_clia_pipeline("item_data", "nf_b2f_version") }},
            {{ rename_clia_pipeline("item_data", "pipeline_name") }},
            {{ rename_clia_pipeline("item_data", "pipeline_version") }},
            {{ json_extract("item_data", ["outputs", "model_results"]) }}
            as model_results,
            {{ json_extract("item_data", ["outputs", "qc_metrics"]) }} as qc_metrics,
            item_data as original_data,
            hash_id,
            emitted_at,
            modified_at,
            -- FIO pipeline scope flag (date-independent)
            pipeline_name in ('multicancer', 'pancv2', 'bioclin') as _in_fio_scope
        from filtered_src
    ),

    -- LabVantage job creation timestamp — rebuild-safe, external LIMS source.
    -- Used for FIO effective-date comparisons in place of modified_at.
    lv_jobs as (select job_id, created_at from {{ ref("lv__u_job") }}),

    -- Enrich with job_created_at and pre-compute FIO date flags using it.
    -- COALESCE falls back to modified_at for ~0.6% of records not in lv__u_job.
    enriched_src as (
        select
            transformed_src.*,
            coalesce(lv_jobs.created_at, transformed_src.modified_at) as job_created_at,
            coalesce(lv_jobs.created_at, transformed_src.modified_at)
            >= to_timestamp_tz('{{ var("fio1_effective_date") }}') as _after_fio1_date,
            coalesce(lv_jobs.created_at, transformed_src.modified_at)
            >= to_timestamp_tz('{{ var("fio2_effective_date") }}') as _after_fio2_date
        from transformed_src
        left join lv_jobs using (job_id)
    ),

    {#
        FIO (For Information Only) overrides (DO-275, CFP-2):
        All 8 metrics are applied in a single nested object_insert expression,
        replacing the prior 8-CTE chain. Each metric sub-object is patched
        independently (no cross-metric dependencies), so nesting is semantically
        equivalent to the chain.

        FIO1 (DO-275): wgs/hmc_pcr_efficiency, cfdna_extraction_efficiency,
                       hmc/wgs_prepcr_lib_hg_dna_ng, wgs_mass_ratio_error_factor
        FIO2 (CFP-2):  hmc/wgs_duplication_pct
    #}
    qc_converted_to_fio as (
        select
            job_id,
            dna_id,
            trf_id,
            clia_env_version,
            env_version,
            b2f_version,
            nf_b2f_version,
            pipeline_name,
            pipeline_version,
            model_results,
            original_data,
            hash_id,
            emitted_at,
            modified_at,
            object_insert(  -- wgs_duplication_pct  (FIO2, outermost)
                object_insert(  -- hmc_duplication_pct  (FIO2)
                    object_insert(  -- wgs_prepcr_lib_hg_dna_ng  (FIO1)
                        object_insert(  -- wgs_mass_ratio_error_factor  (FIO1)
                            object_insert(  -- hmc_prepcr_lib_hg_dna_ng  (FIO1)
                                object_insert(  -- cfdna_extraction_efficiency  (FIO1)
                                    object_insert(  -- hmc_pcr_efficiency  (FIO1)
                                        object_insert(  -- wgs_pcr_efficiency  (FIO1, innermost)
                                            qc_metrics,
                                            'wgs_pcr_efficiency',
                                            iff(
                                                _in_fio_scope
                                                and _after_fio1_date
                                                and qc_metrics:wgs_pcr_efficiency.pass
                                                is not null,
                                                object_insert(
                                                    qc_metrics:wgs_pcr_efficiency,
                                                    'pass',
                                                    true,
                                                    true
                                                ),
                                                qc_metrics:wgs_pcr_efficiency
                                            ),
                                            true
                                        ),
                                        'hmc_pcr_efficiency',
                                        iff(
                                            _in_fio_scope
                                            and _after_fio1_date
                                            and qc_metrics:hmc_pcr_efficiency.pass
                                            is not null,
                                            object_insert(
                                                qc_metrics:hmc_pcr_efficiency,
                                                'pass',
                                                true,
                                                true
                                            ),
                                            qc_metrics:hmc_pcr_efficiency
                                        ),
                                        true
                                    ),
                                    'cfdna_extraction_efficiency',
                                    iff(
                                        _in_fio_scope
                                        and _after_fio1_date
                                        and qc_metrics:cfdna_extraction_efficiency.pass
                                        is not null,
                                        object_insert(
                                            qc_metrics:cfdna_extraction_efficiency,
                                            'pass',
                                            true,
                                            true
                                        ),
                                        qc_metrics:cfdna_extraction_efficiency
                                    ),
                                    true
                                ),
                                'hmc_prepcr_lib_hg_dna_ng',
                                iff(
                                    _in_fio_scope
                                    and _after_fio1_date
                                    and qc_metrics:hmc_prepcr_lib_hg_dna_ng.pass
                                    is not null,
                                    object_insert(
                                        qc_metrics:hmc_prepcr_lib_hg_dna_ng,
                                        'pass',
                                        true,
                                        true
                                    ),
                                    qc_metrics:hmc_prepcr_lib_hg_dna_ng
                                ),
                                true
                            ),
                            'wgs_mass_ratio_error_factor',
                            iff(
                                _in_fio_scope
                                and _after_fio1_date
                                and qc_metrics:wgs_mass_ratio_error_factor.pass
                                is not null,
                                object_insert(
                                    qc_metrics:wgs_mass_ratio_error_factor,
                                    'pass',
                                    true,
                                    true
                                ),
                                qc_metrics:wgs_mass_ratio_error_factor
                            ),
                            true
                        ),
                        'wgs_prepcr_lib_hg_dna_ng',
                        iff(
                            _in_fio_scope
                            and _after_fio1_date
                            and qc_metrics:wgs_prepcr_lib_hg_dna_ng.pass is not null,
                            object_insert(
                                qc_metrics:wgs_prepcr_lib_hg_dna_ng, 'pass', true, true
                            ),
                            qc_metrics:wgs_prepcr_lib_hg_dna_ng
                        ),
                        true
                    ),
                    'hmc_duplication_pct',
                    iff(
                        _in_fio_scope
                        and _after_fio2_date
                        and qc_metrics:hmc_duplication_pct.pass is not null,
                        object_insert(
                            qc_metrics:hmc_duplication_pct, 'pass', true, true
                        ),
                        qc_metrics:hmc_duplication_pct
                    ),
                    true
                ),
                'wgs_duplication_pct',
                iff(
                    _in_fio_scope
                    and _after_fio2_date
                    and qc_metrics:wgs_duplication_pct.pass is not null,
                    object_insert(qc_metrics:wgs_duplication_pct, 'pass', true, true),
                    qc_metrics:wgs_duplication_pct
                ),
                true
            ) as qc_metrics
        from enriched_src
    ),

    -- Extract individual metric columns from the (post-FIO-override) qc_metrics JSON
    final as (
        select
            job_id,
            dna_id,
            trf_id,
            coalesce(clia_env_version, env_version) as clia_env_version,
            b2f_version,
            nf_b2f_version,
            pipeline_name,
            pipeline_version,
            model_results,

            -- HMC QC metrics (extracted from qc_metrics JSON)
            try_to_double(
                qc_metrics:hmc_genebody_zero_fragments.value::string
            ) as hmc_genebody_zero_fragments,
            try_to_double(
                qc_metrics:hmc_duplication_pct.value::string
            ) as hmc_duplication_pct,
            try_to_double(
                qc_metrics:hmc_unique_fragments.value::string
            ) as hmc_unique_fragments,
            null::float as hmc_zero_cpg_count,
            try_to_double(
                qc_metrics:hmc_zero_cpg_fraction.value::string
            ) as hmc_zero_cpg_fraction,

            -- WGS QC metrics (extracted from qc_metrics JSON)
            try_to_double(
                qc_metrics:wgs_mass_ratio_error_factor.value::string
            ) as wgs_mass_ratio_error_factor,
            try_to_double(
                qc_metrics:wgs_unique_fragments.value::string
            ) as wgs_unique_fragments,
            try_to_double(
                qc_metrics:wgs_duplication_pct.value::string
            ) as wgs_duplication_pct,
            try_to_double(
                qc_metrics:wgs_genebody_zero_fragments.value::string
            ) as wgs_genebody_zero_fragments,

            -- v2-only metrics (extracted from qc_metrics JSON)
            try_to_double(
                qc_metrics:cfdna_extraction_efficiency.value::string
            ) as cfdna_extraction_efficiency,
            try_to_double(
                qc_metrics:hmc_pcr_efficiency.value::string
            ) as hmc_pcr_efficiency,
            try_to_double(
                qc_metrics:hmc_prepcr_lib_hg_dna_ng.value::string
            ) as hmc_prepcr_lib_hg_dna_ng,
            try_to_double(
                qc_metrics:wgs_pcr_efficiency.value::string
            ) as wgs_pcr_efficiency,
            try_to_double(
                qc_metrics:wgs_prepcr_lib_hg_dna_ng.value::string
            ) as wgs_prepcr_lib_hg_dna_ng,

            -- pharma-in-clin metrics for DO-554
            try_to_double(
                original_data:outputs.metrics.hmc.total_fragments.value::string
            ) as hmc_total_fragments,
            try_to_double(
                original_data:outputs.metrics.wgs.total_fragments.value::string
            ) as wgs_total_fragments,
            try_to_double(
                original_data:outputs.metrics.wgs.zero_cpg_fraction.value::string
            ) as wgs_zero_cpg_fraction,
            try_to_double(
                original_data:outputs:metrics:plasma_cfdna_fluorescence_conc_ng_ml.value
                ::string
            ) as plasma_cfdna_fluorescence_conc_ng_ml,

            -- Pass/fail flags (extracted from post-FIO-override qc_metrics JSON)
            qc_metrics:hmc_genebody_zero_fragments.pass::boolean
            as is_pass_hmc_genebody_zero_fragments,
            qc_metrics:hmc_duplication_pct.pass::boolean as is_pass_hmc_duplication_pct,
            qc_metrics:hmc_unique_fragments.pass::boolean
            as is_pass_hmc_unique_fragments,
            qc_metrics:hmc_zero_cpg_fraction.pass::boolean
            as is_pass_hmc_zero_cpg_fraction,
            qc_metrics:wgs_mass_ratio_error_factor.pass::boolean
            as is_pass_wgs_mass_ratio_error_factor,
            qc_metrics:wgs_unique_fragments.pass::boolean
            as is_pass_wgs_unique_fragments,
            qc_metrics:wgs_duplication_pct.pass::boolean as is_pass_wgs_duplication_pct,
            qc_metrics:wgs_genebody_zero_fragments.pass::boolean
            as is_pass_wgs_genebody_zero_fragments,
            qc_metrics:cfdna_extraction_efficiency.pass::boolean
            as is_pass_cfdna_extraction_efficiency,
            qc_metrics:hmc_pcr_efficiency.pass::boolean as is_pass_hmc_pcr_efficiency,
            qc_metrics:hmc_prepcr_lib_hg_dna_ng.pass::boolean
            as is_pass_hmc_prepcr_lib_hg_dna_ng,
            qc_metrics:wgs_pcr_efficiency.pass::boolean as is_pass_wgs_pcr_efficiency,
            qc_metrics:wgs_prepcr_lib_hg_dna_ng.pass::boolean
            as is_pass_wgs_prepcr_lib_hg_dna_ng,

            -- qc_metrics JSON blob (passed through with FIO overrides applied)
            -- Preserves original JSON structure for LabVantage consumption
            qc_metrics,

            -- Raw JSON blobs for downstream querying
            -- v2 embeds both HMC and WGS metrics in a single qc_metrics JSON,
            -- so both raw columns reference the full blob
            qc_metrics as hmc_qc_json_raw,
            qc_metrics as wgs_qc_json_raw,

            original_data,
            hash_id,
            emitted_at,
            modified_at
        from qc_converted_to_fio
    )

select *
from final
