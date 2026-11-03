{% set src = ref("stg_clinpipe__results_combined") %}

with
    src as (
        select *
        from {{ src }}
        where get_path(model_results, 'outputs.alternate_group_results') is not null
    ),
    json_extracted as (
        select
            job_id,
            hash_id,
            emitted_at,
            -- FUT-high
            get_path(
                model_results, 'outputs.alternate_group_results."FUT-high".score'
            ) as fut_high_score_raw,
            get_path(
                model_results,
                'outputs.alternate_group_results."FUT-high".ca_19_9_norm_log'
            ) as fut_high_ca_19_9_norm_log_raw,
            -- FUT-intermediate
            get_path(
                model_results,
                'outputs.alternate_group_results."FUT-intermediate".score'
            ) as fut_intermediate_score_raw,
            get_path(
                model_results,
                'outputs.alternate_group_results."FUT-intermediate".ca_19_9_norm_log'
            ) as fut_intermediate_ca_19_9_norm_log_raw,
            -- FUT-low
            get_path(
                model_results, 'outputs.alternate_group_results."FUT-low".score'
            ) as fut_low_score_raw,
            get_path(
                model_results,
                'outputs.alternate_group_results."FUT-low".ca_19_9_norm_log'
            ) as fut_low_ca_19_9_norm_log_raw,
            -- FUT3-null_CA199
            get_path(
                model_results, 'outputs.alternate_group_results."FUT3-null_CA199".score'
            ) as fut3_ca199_null_score_raw,
            get_path(
                model_results,
                'outputs.alternate_group_results."FUT3-null_CA199".ca_19_9_norm_log'
            ) as fut3_ca199_null_ca_19_9_norm_log_raw,
            -- FUT3-null_noCA199
            get_path(
                model_results,
                'outputs.alternate_group_results."FUT3-null_noCA199".score'
            ) as fut3_noca199_null_score_raw,
            get_path(
                model_results,
                'outputs.alternate_group_results."FUT3-null_noCA199".ca_19_9_norm_log'
            ) as fut3_noca199_null_ca_19_9_norm_log_raw,
            -- Other fields
            get_path(model_results, 'outputs.ca_19_9_adjusted') as ca_19_9_adjusted,
            get_path(model_results, 'outputs.ca_19_9_norm_log') as ca_19_9_norm_log_raw,
            get_path(model_results, 'outputs.fut_group_used') as fut_group_used_raw
        from src
    ),
    final as (
        select
            job_id,
            fut_high_score_raw::float as fut_high_score,
            fut_high_ca_19_9_norm_log_raw::float as fut_high_ca_19_9_norm_log,
            fut_intermediate_score_raw::float as fut_intermediate_score,
            fut_intermediate_ca_19_9_norm_log_raw::float
            as fut_intermediate_ca_19_9_norm_log,
            fut_low_score_raw::float as fut_low_score,
            fut_low_ca_19_9_norm_log_raw::float as fut_low_ca_19_9_norm_log,
            fut3_ca199_null_score_raw::float as fut3_ca199_null_score,
            fut3_ca199_null_ca_19_9_norm_log_raw::float
            as fut3_ca199_null_ca_19_9_norm_log,
            fut3_noca199_null_score_raw::float as fut3_noca199_null_score,
            fut3_noca199_null_ca_19_9_norm_log_raw::float
            as fut3_noca199_null_ca_19_9_norm_log,
            ca_19_9_adjusted::float as ca_19_9_adjusted,
            ca_19_9_norm_log_raw::float as ca_19_9_norm_log,
            fut_group_used_raw::varchar as fut_group_used,
            hash_id,
            emitted_at
        from json_extracted
    )
select *
from final
