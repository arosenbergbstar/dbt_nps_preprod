{% set src = source("clin_pipeline", "jobs") %}
{% set col_list = get_json_keys(src, "data") %}

with
    dedup_src as (
        {{
            dbt_utils.deduplicate(
                relation=src,
                partition_by="event",
                order_by="emitted_at::timestamp_tz asc",
            )
        }}
    ),

    final as (
        select
            dedup_src.event,
            {% for col in col_list %}
                {{ rename_clia_pipeline("data", col) }},
            {% endfor %}
            emitted_at::timestamp_tz as emitted_at
        from dedup_src
    )

select *
from final
