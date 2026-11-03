with
    clia_pipeline_results as (
        select
            * exclude (hmc_qc_zero_cpg, wgs_qc_zero_cpg, score_cancer),
            score_cancer as score,
            iff(
                hmc_qc_zero_cpg is not null and hmc_qc_zero_cpg != 'None',
                1.0 * hmc_qc_zero_cpg / hmc_qc_unique_fragments,
                null
            )::varchar as hmc_qc_zero_cpg,
            iff(
                wgs_qc_zero_cpg is not null and wgs_qc_zero_cpg != 'None',
                1.0 * wgs_qc_zero_cpg / wgs_qc_unique_fragments,
                null
            )::varchar as wgs_qc_zero_cpg
        from {{ ref("clia_pipeline__results") }}
        where event like 'J-%'
    ),
    unpivoted as (
        select
            job_id,  -- replace with your actual grain columns
            pipeline_name,
            key as qc_field_name,
            value as qc_field_value
        from
            clia_pipeline_results unpivot (
                value for key in (
                    hmc_qc_num_zero,
                    hmc_qc_perc_dup,
                    hmc_qc_unique_fragments,
                    hmc_qc_zero_cpg,
                    wgs_qc_num_zero,
                    wgs_qc_perc_dup,
                    wgs_qc_unique_fragments,
                    wgs_qc_mass_ratio_error_factor, 
                    score
                )
            )
    ),
    result_qc_thresholds as (
        select *, {{ map_workflow_type("workflow_type") }} as pipeline_name
        from {{ ref("lv__specparamlimits") }}
        where
            pipeline_name in ('pancreatic', 'ovarian')
            and param_list_id in ('WGS Sample', '5hmC Sample')
            {# 
                Selects the correct row from specparamlimits for each metric.
                
                - For % Duplication, Num Zero and 0 CPG it is true for rows with less than (<)
                - For all other metrics it is true for rows with greater than or equal to (>=)
                - If operator2 is not null it will set to false - only borderline cancer score 
                  uses operator2, which the model calculates independently.
         #}
            and case
                when operator2 is not null and lower(metric_name) = 'score'
                then false
                when
                    (
                        lower(metric_name) like '%perc_dup'
                        or lower(metric_name) like '%num_zero'
                        or lower(metric_name) like '%zero_cpg%'
                    )
                    and operator1 = '<'
                then true
                when
                    (
                        lower(metric_name) not like '%perc_dup'
                        and lower(metric_name) not like '%num_zero'
                        and lower(metric_name) not like '%zero_cpg%'
                    )
                    and operator1 = '>='
                then true
                else false
            end
    ),
    qc_evalutations as (
        select
            unpivoted.*,
            result_qc_thresholds.operator1,
            result_qc_thresholds.metric_value1,
            {{
                eval_inequality(
                    "result_qc_thresholds.operator1",
                    "qc_field_value",
                    "result_qc_thresholds.metric_value1",
                )
            }} as qc_result
        from unpivoted
        left join
            result_qc_thresholds
            on qc_field_name = metric_name
            and result_qc_thresholds.pipeline_name = unpivoted.pipeline_name
    ),
    qc_evaluations_flattened as (
        select
            job_id,
            max(
                iff(qc_field_name = 'SCORE', qc_result, null)
            ) as is_cancer_detected,
            max(
                iff(qc_field_name = 'HMC_QC_NUM_ZERO', qc_result, null)
            ) as has_passed_hmc_qc_num_zero,
            max(
                iff(qc_field_name = 'HMC_QC_PERC_DUP', qc_result, null)
            ) as has_passed_hmc_qc_perc_dup,
            max(
                iff(qc_field_name = 'HMC_QC_UNIQUE_FRAGMENTS', qc_result, null)
            ) as has_passed_hmc_qc_unique_fragments,
            max(
                iff(qc_field_name = 'HMC_QC_ZERO_CPG', qc_result, null)
            ) as has_passed_hmc_qc_zero_cpg_fraction,
            max(
                iff(qc_field_name = 'WGS_QC_NUM_ZERO', qc_result, null)
            ) as has_passed_wgs_qc_num_zero,
            max(
                iff(qc_field_name = 'WGS_QC_PERC_DUP', qc_result, null)
            ) as has_passed_wgs_qc_perc_dup,
            max(
                iff(qc_field_name = 'WGS_QC_UNIQUE_FRAGMENTS', qc_result, null)
            ) as has_passed_wgs_qc_unique_fragments,
            max(
                iff(qc_field_name = 'WGS_QC_MASS_RATIO_ERROR_FACTOR', qc_result, null)
            ) as has_passed_wgs_qc_mass_ratio_error_factor
        from qc_evalutations
        group by job_id
    ),
    final as (
        select
            job_id,
            hmc_qc_num_zero::float as hmc_qc_num_zero,
            has_passed_hmc_qc_num_zero,
            hmc_qc_perc_dup::float as hmc_qc_perc_dup,
            has_passed_hmc_qc_perc_dup,
            hmc_qc_unique_fragments::float as hmc_qc_unique_fragments,
            has_passed_hmc_qc_unique_fragments,
            hmc_qc_zero_cpg::float as hmc_qc_zero_cpg_fraction,
            has_passed_hmc_qc_zero_cpg_fraction,
            wgs_qc_num_zero::float as wgs_qc_num_zero,
            has_passed_wgs_qc_num_zero,
            wgs_qc_perc_dup::float as wgs_qc_perc_dup,
            has_passed_wgs_qc_perc_dup,
            wgs_qc_unique_fragments::float as wgs_qc_unique_fragments,
            has_passed_wgs_qc_unique_fragments,
            wgs_qc_zero_cpg::float as wgs_qc_zero_cpg_fraction,
            wgs_qc_mass_ratio_error_factor::float as wgs_qc_mass_ratio_error_factor,
            has_passed_wgs_qc_mass_ratio_error_factor,
            score::float as score,
            is_cancer_detected
        from clia_pipeline_results
        left join qc_evaluations_flattened using (job_id)
    )

select *
from final
