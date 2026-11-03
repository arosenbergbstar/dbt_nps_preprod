{#
    Extracts pipeline results and QC metrics from v1 pipeline JSON (ovarian, pancreatic).

    v1 pipelines store results in a flat JSON structure with hmc_qc and wgs_qc at root level.
    This model extracts metrics to individual columns and constructs a qc_metrics JSON blob
    for LabVantage consumption. See stg_clinpipe__results_json_v2 for the v2 equivalent.

    Pipeline list defined in dbt_project.yml var: clinpipe_v1_pipelines
#}

with
    src as (select * from {{ ref("int_clinpipe__versioned_results") }}),

    -- Explicit enumeration of v1 pipelines
    filtered_src as (
        select * from src where pipeline_name in ('{{ var('clinpipe_v1_pipelines') | join("', '") }}')
    ),

    transformed_src as (
        select
            -- Identifiers
            coalesce(
                {{ json_extract_scalar("item_data", ["job_id"]) }},
                {{ json_extract_scalar("item_data", ["jobid"]) }}
            ) as job_id,
            {{ rename_clia_pipeline("item_data", "dna_id") }},
            {{ rename_clia_pipeline("item_data", "trf_id") }},
            {{ rename_clia_pipeline("item_data", "clia_env_version") }},
            {{ rename_clia_pipeline("item_data", "b2f_version") }},
            {{ rename_clia_pipeline("item_data", "nf_b2f_version") }},
            {{ rename_clia_pipeline("item_data", "pipeline_name") }},
            {{ rename_clia_pipeline("item_data", "pipeline_version") }},

            -- Model results (kept as JSON for compatibility)
            object_construct_keep_null(
                'cancer',
                object_construct_keep_null(
                    'score',
                    try_to_double(
                        {{ json_extract_scalar("item_data", ["score_cancer"]) }}
                    )
                )
            ) as model_results,

            -- HMC QC metrics
            try_to_double(
                {{ json_extract_scalar("item_data", ["hmc_qc", "num_zero"]) }}
            ) as hmc_genebody_zero_fragments,

            try_to_double(
                {{ json_extract_scalar("item_data", ["hmc_qc", "perc_dup"]) }}
            ) as hmc_duplication_pct,

            try_to_double(
                {{ json_extract_scalar("item_data", ["hmc_qc", "unique_fragments"]) }}
            ) as hmc_unique_fragments,

            try_to_double(
                {{ json_extract_scalar("item_data", ["hmc_qc", "zero_cpg"]) }}
            ) as hmc_zero_cpg_count,

            -- v1 raw data has zero_cpg count but not fraction; calculate it here.
            -- Returns NULL if unique_fragments = 0 (undefined fraction for failed samples).
            try_to_double(
                {{ json_extract_scalar("item_data", ["hmc_qc", "zero_cpg"]) }}
            ) / nullif(
                try_to_double(
                    {{ json_extract_scalar("item_data", ["hmc_qc", "unique_fragments"]) }}
                ),
                0
            ) as hmc_zero_cpg_fraction,

            -- WGS QC metrics
            try_to_double(
                {{ json_extract_scalar("item_data", ["wgs_qc", "mass_ratio_error_factor"]) }}
            ) as wgs_mass_ratio_error_factor,

            try_to_double(
                {{ json_extract_scalar("item_data", ["wgs_qc", "unique_fragments"]) }}
            ) as wgs_unique_fragments,

            try_to_double(
                {{ json_extract_scalar("item_data", ["wgs_qc", "perc_dup"]) }}
            ) as wgs_duplication_pct,

            try_to_double(
                {{ json_extract_scalar("item_data", ["wgs_qc", "num_zero"]) }}
            ) as wgs_genebody_zero_fragments,

            -- v2-only metrics (NULL for v1 pipelines)
            null::float as cfdna_extraction_efficiency,
            null::float as hmc_pcr_efficiency,
            null::float as hmc_prepcr_lib_hg_dna_ng,
            null::float as wgs_pcr_efficiency,
            null::float as wgs_prepcr_lib_hg_dna_ng,

            -- Pass/fail flags (v1 pipelines don't have these)
            null::boolean as is_pass_hmc_genebody_zero_fragments,
            null::boolean as is_pass_hmc_duplication_pct,
            null::boolean as is_pass_hmc_unique_fragments,
            null::boolean as is_pass_hmc_zero_cpg_fraction,
            null::boolean as is_pass_wgs_mass_ratio_error_factor,
            null::boolean as is_pass_wgs_unique_fragments,
            null::boolean as is_pass_wgs_duplication_pct,
            null::boolean as is_pass_wgs_genebody_zero_fragments,
            null::boolean as is_pass_cfdna_extraction_efficiency,
            null::boolean as is_pass_hmc_pcr_efficiency,
            null::boolean as is_pass_hmc_prepcr_lib_hg_dna_ng,
            null::boolean as is_pass_wgs_pcr_efficiency,
            null::boolean as is_pass_wgs_prepcr_lib_hg_dna_ng,

            -- qc_metrics JSON blob (for LabVantage compatibility)
            -- Constructed to match production schema expected by dbt_prod export tables
            object_construct_keep_null(
                'HMC_QC_NUM_ZERO', object_construct_keep_null(
                    'value', try_to_double({{ json_extract_scalar("item_data", ["hmc_qc", "num_zero"]) }})
                ),
                'HMC_QC_PERC_DUP', object_construct_keep_null(
                    'value', try_to_double({{ json_extract_scalar("item_data", ["hmc_qc", "perc_dup"]) }})
                ),
                'HMC_QC_ZERO_CPG', object_construct_keep_null(
                    'value', try_to_double({{ json_extract_scalar("item_data", ["hmc_qc", "zero_cpg"]) }})
                ),
                'HMC_QC_UNIQUE_FRAGMENTS', object_construct_keep_null(
                    'value', try_to_double({{ json_extract_scalar("item_data", ["hmc_qc", "unique_fragments"]) }})
                ),
                'WGS_QC_MASS_RATIO_ERROR_FACTOR', object_construct_keep_null(
                    'value', try_to_double({{ json_extract_scalar("item_data", ["wgs_qc", "mass_ratio_error_factor"]) }})
                ),
                'WGS_QC_UNIQUE_FRAGMENTS', object_construct_keep_null(
                    'value', try_to_double({{ json_extract_scalar("item_data", ["wgs_qc", "unique_fragments"]) }})
                ),
                'WGS_QC_PERC_DUP', object_construct_keep_null(
                    'value', try_to_double({{ json_extract_scalar("item_data", ["wgs_qc", "perc_dup"]) }})
                ),
                'WGS_QC_NUM_ZERO', object_construct_keep_null(
                    'value', try_to_double({{ json_extract_scalar("item_data", ["wgs_qc", "num_zero"]) }})
                )
            ) as qc_metrics,

            -- Preserved raw JSON for downstream querying
            item_data:hmc_qc as hmc_qc_json_raw,
            item_data:wgs_qc as wgs_qc_json_raw,
            item_data as original_data,
            hash_id,
            emitted_at,
            null::timestamp_tz as modified_at

        from filtered_src
    ),

    final as (select * from transformed_src)

select *
from final
order by emitted_at asc, job_id asc
