{{ config(post_hook=["{{ apply_nodmed_row_access( this ) }}"]) }}

{% set src = source("clin_pipeline", "jobs") %}
{% set col_list = get_json_keys(src, "data") %}

with
    stg_study_samples as (
        select distinct purified_plasma_id, study_id from {{ ref("stg_study_samples") }}
    ),

    dedup_src as (
        {{
            dbt_utils.deduplicate(
                relation=src,
                partition_by="event, md5(data)",
                order_by="emitted_at::timestamp_tz asc",
            )
        }}
    ),

    transformed_src as (
        select
            dedup_src.event,
            {% for col in col_list %}
                {{ rename_clia_pipeline("data", col) }},
            {% endfor %}
            md5(data) as hash_id,
            emitted_at::timestamp_tz as emitted_at
        from dedup_src
    ),

    final as (
        select transformed_src.*, stg_study_samples.study_id
        from transformed_src
        join
            stg_study_samples
            on stg_study_samples.purified_plasma_id = transformed_src.purified_plasma_id
    )

select *
from final
