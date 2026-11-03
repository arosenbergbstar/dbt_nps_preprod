
{#
    DO-459: QC metrics mart - standardized output

    All QC metrics are extracted and normalized upstream.
    hmc_zero_cpg_fraction is always a fraction (calculated in v1, native in v2).

    Note: Schema matches production BASE.CLIN_PIPELINE.CLINPIPE__QC_METRICS
#}

with
    qc_metrics as (select * from {{ ref("stg_clinpipe__qc_metrics") }}),

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
        from qc_metrics
    )

select *
from final
