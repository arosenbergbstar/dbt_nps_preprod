with
    jobs as (
        select
            job_id,
            trf_id,
            purified_plasma_id,
            cfdna_id,
            purified_plasma_sample_id,
            hmc_seq_id,
            wgs_seq_id,
            hmc_flow_cell_id,
            wgs_flow_cell_id,
            hmc_index_i5,
            hmc_index_i7,
            wgs_index_i5,
            wgs_index_i7,
            purified_plasma_vol,
            buffer_top_off_vol,
            extraction_input_vol,
            extraction_elution_vol,
            cfdna_conc,
            input_dna,
            wgs_lib_conc,
            hmc_lib_conc,
            purified_plasma_test,
            pipeline_name,
            pipeline_version,
            b2f_version,
            nf_b2f_version,
            clia_env_version,
            has_sample_results_received,
            has_hmc_flow_cell_results_received,
            has_wgs_flow_cell_results_received,
            score,
            qc_metrics,
            biomarkers,
            sample_type,
            patient_sex_at_birth,
            patient_age,
            modified_at,
            created_at,
            canceled_at
        from {{ ref("lv__u_job") }}
    )

select *
from jobs
