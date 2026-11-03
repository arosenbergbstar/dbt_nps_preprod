with
    clinpipe__jobs_status as (
        {{
            dbt_utils.deduplicate(
                relation=ref("clinpipe__jobs_status"),
                partition_by="job_id",
                order_by="updated_at desc",
            )
        }}
    ),
    clinpipe__model_results_cancer as (
        {{
            dbt_utils.deduplicate(
                relation=ref("clinpipe__model_results_cancer"),
                partition_by="job_id",
                order_by="emitted_at desc",
            )
        }}
    ),
    clinpipe__qc_metrics as (
        {{
            dbt_utils.deduplicate(
                relation=ref("clinpipe__qc_metrics"),
                partition_by="job_id",
                order_by="emitted_at desc",
            )
        }}
    ),
    clinpipe__qc_all as (
        select
            job_id,
            least(
                iff(
                    is_pass_hmc_duplication_pct is null,
                    true,
                    is_pass_hmc_duplication_pct
                )::integer,
                iff(
                    is_pass_hmc_unique_fragments is null,
                    true,
                    is_pass_hmc_unique_fragments
                )::integer,
                iff(
                    is_pass_hmc_zero_cpg_fraction is null,
                    true,
                    is_pass_hmc_zero_cpg_fraction
                )::integer,
                iff(
                    is_pass_wgs_mass_ratio_error_factor is null,
                    true,
                    is_pass_wgs_mass_ratio_error_factor
                )::integer,
                iff(
                    is_pass_wgs_genebody_zero_fragments is null,
                    true,
                    is_pass_wgs_genebody_zero_fragments
                )::integer,
                iff(
                    is_pass_wgs_duplication_pct is null,
                    true,
                    is_pass_wgs_duplication_pct
                )::integer,
                iff(
                    is_pass_wgs_unique_fragments is null,
                    true,
                    is_pass_wgs_unique_fragments
                )::integer
            )::boolean as is_pass_qc_all
        from {{ ref("clinpipe__qc_metrics") }}
    ),
    clinpipe__model_results_toto as (
        {{
            dbt_utils.deduplicate(
                relation=ref("clinpipe__model_results_toto"),
                partition_by="job_id",
                order_by="emitted_at desc",
            )
        }}
    ),
    clinpipe__model_results_fut as (
        {{
            dbt_utils.deduplicate(
                relation=ref("clinpipe__model_results_fut"),
                partition_by="job_id",
                order_by="emitted_at desc",
            )
        }}
    ),
    main as (
        select
            job_id,
            clinpipe__model_results_cancer.cancer as is_cancer_indicated,
            clinpipe__model_results_cancer.score as cancer_score,
            clinpipe__model_results_toto.prediction_primary,
            clinpipe__model_results_toto.prediction_secondary,
            clinpipe__model_results_toto.breast,
            clinpipe__model_results_toto.colorectal,
            clinpipe__model_results_toto.esophagus_gastric,
            clinpipe__model_results_toto.liver,
            clinpipe__model_results_toto.lung,
            clinpipe__model_results_toto.ovary,
            clinpipe__model_results_toto.pancreas,
            clinpipe__qc_metrics.hmc_total_fragments,
            clinpipe__qc_metrics.wgs_total_fragments,
            clinpipe__qc_metrics.wgs_zero_cpg_fraction,
            clinpipe__qc_metrics.plasma_cfdna_fluorescence_conc_ng_ml,
            clinpipe__qc_metrics.cfdna_extraction_efficiency,
            clinpipe__qc_metrics.is_pass_cfdna_extraction_efficiency,
            clinpipe__qc_metrics.hmc_pcr_efficiency,
            clinpipe__qc_metrics.is_pass_hmc_pcr_efficiency,
            clinpipe__qc_metrics.hmc_prepcr_lib_hg_dna_ng,
            clinpipe__qc_metrics.is_pass_hmc_prepcr_lib_hg_dna_ng,
            clinpipe__qc_metrics.hmc_genebody_zero_fragments,
            clinpipe__qc_metrics.is_pass_hmc_genebody_zero_fragments,
            clinpipe__qc_metrics.hmc_duplication_pct,
            clinpipe__qc_metrics.is_pass_hmc_duplication_pct,
            clinpipe__qc_metrics.hmc_unique_fragments,
            clinpipe__qc_metrics.is_pass_hmc_unique_fragments,
            clinpipe__qc_metrics.hmc_zero_cpg_fraction,
            clinpipe__qc_metrics.is_pass_hmc_zero_cpg_fraction,
            clinpipe__qc_metrics.wgs_pcr_efficiency,
            clinpipe__qc_metrics.is_pass_wgs_pcr_efficiency,
            clinpipe__qc_metrics.wgs_prepcr_lib_hg_dna_ng,
            clinpipe__qc_metrics.is_pass_wgs_prepcr_lib_hg_dna_ng,
            clinpipe__qc_metrics.wgs_mass_ratio_error_factor,
            clinpipe__qc_metrics.is_pass_wgs_mass_ratio_error_factor,
            clinpipe__qc_metrics.wgs_genebody_zero_fragments,
            clinpipe__qc_metrics.is_pass_wgs_genebody_zero_fragments,
            clinpipe__qc_metrics.wgs_duplication_pct,
            clinpipe__qc_metrics.is_pass_wgs_duplication_pct,
            clinpipe__qc_metrics.wgs_unique_fragments,
            clinpipe__qc_metrics.is_pass_wgs_unique_fragments,
            clinpipe__qc_all.is_pass_qc_all,
            clinpipe__model_results_fut.fut_high_score,
            clinpipe__model_results_fut.fut_high_ca_19_9_norm_log,
            clinpipe__model_results_fut.fut_intermediate_score,
            clinpipe__model_results_fut.fut_intermediate_ca_19_9_norm_log,
            clinpipe__model_results_fut.fut_low_score,
            clinpipe__model_results_fut.fut_low_ca_19_9_norm_log,
            clinpipe__model_results_fut.fut3_ca199_null_score,
            clinpipe__model_results_fut.fut3_ca199_null_ca_19_9_norm_log,
            clinpipe__model_results_fut.fut3_noca199_null_score,
            clinpipe__model_results_fut.fut3_noca199_null_ca_19_9_norm_log,
            clinpipe__model_results_fut.ca_19_9_adjusted,
            clinpipe__model_results_fut.ca_19_9_norm_log,
            clinpipe__model_results_fut.fut_group_used
        from clinpipe__model_results_cancer
        inner join clinpipe__qc_metrics using (job_id)
        inner join clinpipe__qc_all using (job_id)
        inner join clinpipe__jobs_status using (job_id)
        left join clinpipe__model_results_toto using (job_id)
        left join clinpipe__model_results_fut using (job_id)
        where pipeline_name not in ('pancreatic', 'ovarian')

    )

select *
from main
