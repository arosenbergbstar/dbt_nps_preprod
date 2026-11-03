{#
    QC metrics staging - pass-through from combined staging.

    QC metrics are extracted as columns upstream in the v1/v2 staging models.
    This model passes through standardized columns with consistent naming.

    Note: pipeline_name kept here for internal use (tests, debugging)
          but removed in the mart to match production schema.
#}

with
    src as (select * from {{ ref("stg_clinpipe__results_combined") }}),

    final as (
        select
            job_id,
            pipeline_name,

            -- v2-only metrics
            cfdna_extraction_efficiency,
            is_pass_cfdna_extraction_efficiency,
            hmc_pcr_efficiency,
            is_pass_hmc_pcr_efficiency,
            hmc_prepcr_lib_hg_dna_ng,
            is_pass_hmc_prepcr_lib_hg_dna_ng,

            -- HMC QC metrics
            hmc_genebody_zero_fragments,
            is_pass_hmc_genebody_zero_fragments,
            hmc_duplication_pct,
            is_pass_hmc_duplication_pct,
            hmc_unique_fragments,
            is_pass_hmc_unique_fragments,
            hmc_zero_cpg_count,
            hmc_zero_cpg_fraction,
            is_pass_hmc_zero_cpg_fraction,

            -- WGS QC metrics
            wgs_pcr_efficiency,
            is_pass_wgs_pcr_efficiency,
            wgs_prepcr_lib_hg_dna_ng,
            is_pass_wgs_prepcr_lib_hg_dna_ng,
            wgs_mass_ratio_error_factor,
            is_pass_wgs_mass_ratio_error_factor,
            wgs_genebody_zero_fragments,
            is_pass_wgs_genebody_zero_fragments,
            wgs_duplication_pct,
            is_pass_wgs_duplication_pct,
            wgs_unique_fragments,
            is_pass_wgs_unique_fragments,

            -- Pharma-in-Clin metrics
            hmc_total_fragments,
            wgs_total_fragments,
            wgs_zero_cpg_fraction,
            plasma_cfdna_fluorescence_conc_ng_ml,

            -- Raw JSON blobs (preserved for downstream querying)
            hmc_qc_json_raw,
            wgs_qc_json_raw,

            -- qc_metrics JSON blob for LabVantage consumption.
            -- Note: v1 uses uppercase keys (HMC_QC_NUM_ZERO), v2 uses lowercase
            -- (hmc_genebody_zero_fragments). LabVantage handles both formats.
            qc_metrics,

            hash_id,
            emitted_at
        from src
    )

select *
from final
