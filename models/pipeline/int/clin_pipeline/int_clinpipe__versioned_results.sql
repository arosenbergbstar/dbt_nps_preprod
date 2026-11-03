{# v1 of the results json schema #}
{% set src = source("clin_pipeline_snowpipe", "results") %}
{% set col_list = get_json_keys(src, "item_data") %}

with
    dedup_src as (
        {{
            dbt_utils.deduplicate(
                relation=src,
                partition_by="event, md5(item_data)",
                order_by="emitted_at::timestamp_tz asc",
            )
        }}
    ),

    final as (
        select
            item_data:pipeline_name as pipeline_name,
            regexp_substr(item_data:pipeline_version, '[0-9+]', 1, 1)::int
            as major_pipeline_version,
            regexp_substr(item_data:pipeline_version, '[0-9+]', 1, 2)::int
            as minor_pipeline_version,
            event,
            item_data,
            md5(item_data) as hash_id,
            emitted_at::timestamp_tz as emitted_at,
            modified_at::timestamp_tz as modified_at
        from dedup_src
    )

select *
from final
