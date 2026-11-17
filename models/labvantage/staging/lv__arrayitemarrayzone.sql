{% set src = source("labvantage", "arrayitemarrayzone") %}

with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("MODDT") }} as modified_at,
            {{ adapter.quote("TRACELOGID") }} as trace_log_id,
            {{ adapter.quote("MODTOOL") }} as modified_tool,
            {{ adapter.quote("CREATEBY") }} as created_by,
            {{ adapter.quote("AUDITSEQUENCE") }} as audit_sequence,
            {{ adapter.quote("ARRAYZONEID") }} as array_zone_id,
            {{ adapter.quote("MODBY") }} as modified_by,
            {{ adapter.quote("USERSEQUENCE") }} as user_sequence,
            {{ adapter.quote("CREATEDT") }} as created_at,
            {{ adapter.quote("CONTENTSTRING") }} as content_string,
            {{ adapter.quote("CREATETOOL") }} as created_tool,
            {{ adapter.quote("ARRAYITEMID") }} as array_item_id,
            {{ airbyte_get_emit_col(src) }} as elt_emitted_at,
            {{ airbyte_get_id_col(src) }} as elt_hash_id
        from source
    ),
    typed as (
        select
            {{ cast_timestamp_tz("modified_at", "UTC") }},
            trace_log_id::text as trace_log_id,
            modified_tool::text as modified_tool,
            created_by::text as created_by,
            audit_sequence::integer as audit_sequence,
            array_zone_id::text as array_zone_id,
            modified_by::text as modified_by,
            user_sequence::integer as user_sequence,
            {{ cast_timestamp_tz("created_at", "UTC") }},
            content_string::text as content_string,
            created_tool::text as created_tool,
            array_item_id::text as array_item_id,
            elt_emitted_at::timestamp_tz as elt_emitted_at,
            elt_hash_id::text as elt_hash_id
        from renamed
    )

select *
from typed
