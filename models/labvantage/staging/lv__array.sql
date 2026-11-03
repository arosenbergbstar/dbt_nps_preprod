{# Renamed and typed LabVantage array table, following the dbt_base lv__ pattern. #}
{% set src = source("labvantage", "array") %}

with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("ARRAYID") }} as array_id,
            {{ adapter.quote("ARRAYDESC") }} as array_desc,
            {{ adapter.quote("ARRAYSTATUS") }} as array_status,
            {{ adapter.quote("ARRAYTYPEID") }} as array_type_id,
            {{ adapter.quote("ARRAYTYPEVERSIONID") }} as array_type_version_id,
            {{ adapter.quote("ARRAYLAYOUTID") }} as array_layout_id,
            {{ adapter.quote("ARRAYLAYOUTVERSIONID") }} as array_layout_version_id,
            {{ adapter.quote("CLASSIFICATION") }} as classification,
            {{ adapter.quote("NOTES") }} as notes,
            {{ adapter.quote("TEMPLATEFLAG") }} as is_template,
            {{ adapter.quote("ACTIVEFLAG") }} as is_active,
            {{ adapter.quote("USERSEQUENCE") }} as user_sequence,
            {{ adapter.quote("AUDITSEQUENCE") }} as audit_sequence,
            {{ adapter.quote("TRACELOGID") }} as trace_log_id,
            {{ adapter.quote("MODTOOL") }} as modified_tool,
            {{ adapter.quote("CREATETOOL") }} as created_tool,
            {{ adapter.quote("MODBY") }} as modified_by,
            {{ adapter.quote("MODDT") }} as modified_at,
            {{ adapter.quote("CREATEBY") }} as created_by,
            {{ adapter.quote("CREATEDT") }} as created_at,
            {{ airbyte_get_emit_col(src) }} as elt_emitted_at,
            {{ airbyte_get_id_col(src) }} as elt_hash_id
        from source
    ),
    typed as (
        select
            array_id::text as array_id,
            array_desc::text as array_desc,
            array_status::text as array_status,
            array_type_id::text as array_type_id,
            array_type_version_id::text as array_type_version_id,
            array_layout_id::text as array_layout_id,
            array_layout_version_id::text as array_layout_version_id,
            classification::text as classification,
            notes::text as notes,
            is_template::boolean as is_template,
            is_active::boolean as is_active,
            user_sequence::integer as user_sequence,
            audit_sequence::integer as audit_sequence,
            trace_log_id::text as trace_log_id,
            modified_tool::text as modified_tool,
            created_tool::text as created_tool,
            modified_by::text as modified_by,
            {{ cast_timestamp_tz("modified_at", "UTC") }},
            created_by::text as created_by,
            {{ cast_timestamp_tz("created_at", "UTC") }},
            elt_emitted_at::timestamp_tz as elt_emitted_at,
            elt_hash_id::text as elt_hash_id
        from renamed
    )

select *
from typed
