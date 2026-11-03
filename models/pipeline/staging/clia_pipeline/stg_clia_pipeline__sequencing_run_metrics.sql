{% set src = source("clin_pipeline", "sequencing_run_metrics") %}
{% set col_list = get_json_keys(src, "data") %}

with
    raw_src as (select * from {{ src }}),

    final as (
        select
            event,
            {% for col in col_list %}
                {{ rename_clia_pipeline("data", col) }},
            {% endfor %}
            md5(data) as hash_id,
            emitted_at::timestamp_tz as emitted_at
        from raw_src
    )

select *
from final
