{% set src = ref("stg_clinpipe__results_combined") %}

with
    src as (
        select *
        from {{ src }}
        where get_path(model_results, 'tissue_of_tumor_origin') is not null
    ),
    final as (
        select
            job_id,
            get_path(model_results, 'tissue_of_tumor_origin.breast') as breast,
            get_path(model_results, 'tissue_of_tumor_origin.colorectal') as colorectal,
            get_path(
                model_results, 'tissue_of_tumor_origin."esophagus-gastric"'
            ) as esophagus_gastric,
            get_path(model_results, 'tissue_of_tumor_origin.liver') as liver,
            get_path(model_results, 'tissue_of_tumor_origin.lung') as lung,
            get_path(model_results, 'tissue_of_tumor_origin.ovary') as ovary,
            get_path(model_results, 'tissue_of_tumor_origin.pancreas') as pancreas,
            get_path(
                model_results, 'tissue_of_tumor_origin.prediction_primary'
            ) as prediction_primary,
            get_path(
                model_results, 'tissue_of_tumor_origin.prediction_secondary'
            ) as prediction_secondary,
            get_path(model_results, 'tissue_of_tumor_origin.precision') as precision,
            get_path(model_results, 'tissue_of_tumor_origin.scale') as scale,
            get_path(model_results, 'tissue_of_tumor_origin.unit') as unit,
            hash_id,
            emitted_at
        from src
    )
select *
from final
