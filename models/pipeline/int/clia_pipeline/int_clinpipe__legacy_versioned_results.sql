{# v1 of the results json schema #}
{% set src = source("clin_pipeline", "results") %}
{% set col_list = get_json_keys(src, "data") %}

with
    dedup_src as (
        {{
            dbt_utils.deduplicate(
                relation=src,
                partition_by="event, md5(data)",
                order_by="emitted_at::timestamp_tz asc",
            )
        }}
    ),

    final as (
        select
            data:pipeline_name as pipeline_name,
            regexp_substr(data:pipeline_version, '[0-9+]', 1, 1)::int
            as major_pipeline_version,
            regexp_substr(data:pipeline_version, '[0-9+]', 1, 2)::int
            as minor_pipeline_version,
            event,
            data,
            md5(data) as hash_id,
            emitted_at::timestamp_tz as emitted_at
        from dedup_src
    )

select *
from final
