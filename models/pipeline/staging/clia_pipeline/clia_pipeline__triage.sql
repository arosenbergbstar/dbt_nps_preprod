{% set src = source("clin_pipeline", "triage") %}
{% set col_list = get_json_keys(src, "data") %}

with
    raw_src as (select * from {{ src }}),

    renamed as (
        select
            event,
            {% for col in col_list %}
                {{ rename_clia_pipeline("data", col) }},
            {% endfor %}
            md5(data) as hash_id,
            emitted_at::timestamp_tz as emitted_at
        from raw_src
    ),

    final as (
        select * exclude (hash_id)
        from renamed
        qualify row_number() over (partition by hash_id order by emitted_at asc) = 1
    )

select *
from final
