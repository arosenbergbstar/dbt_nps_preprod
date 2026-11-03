{% set src = ref("stg_clinpipe__results_combined") %}

with
    src as (select * from {{ src }}),
    final as (
        select
            job_id,
            get_path(model_results, 'cancer.cancer') as cancer,
            get_path(model_results, 'cancer.score') as score,
            get_path(model_results, 'cancer.inequality') as inequality,
            get_path(model_results, 'cancer.threshold') as threshold,
            get_path(model_results, 'cancer.precision') as precision,
            get_path(model_results, 'cancer.scale') as scale,
            get_path(model_results, 'cancer.unit') as unit,
            hash_id,
            emitted_at
        from src
    )
select *
from final
