{#
    DO-459: QC metrics - standardized output

    QC metrics are extracted as columns upstream in the v1/v2 staging models
    (stg_clinpipe__results_json_v1/v2) and unioned in stg_clinpipe__results_combined.
    hmc_zero_cpg_fraction is always a fraction (calculated in v1, native in v2).

    Note: Schema matches production BASE.CLIN_PIPELINE.CLINPIPE__QC_METRICS
#}

with
    src as (select * from {{ ref("stg_clinpipe__results_combined") }}),

    final as (
        select
            job_id,

            -- v2-only metrics (ordered to match production)
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

            hash_id,
            emitted_at
        from src
    )

select *
from final
