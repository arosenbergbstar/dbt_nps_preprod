{# Renamed and typed LabVantage arrayarraymethoditem table, following the dbt_base lv__ pattern. #}
{% set src = source("labvantage", "arrayarraymethoditem") %}

with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("ARRAYID") }} as array_id,
            {{ adapter.quote("ARRAYMETHODID") }} as array_method_id,
            {{ adapter.quote("ARRAYMETHODVERSIONID") }} as array_method_version_id,
            {{ adapter.quote("ARRAYMETHODINSTANCE") }} as array_method_instance,
            {{ adapter.quote("ARRAYMETHODITEMSTATUS") }} as array_method_item_status,
            {{ adapter.quote("INSTRUMENTID") }} as instrument_id,
            {{ adapter.quote("INSTRUMENTTYPEID") }} as instrument_type_id,
            {{ adapter.quote("SAMPLETYPEID") }} as sample_type_id,
            {{ adapter.quote("REVIEWDISPOSITION") }} as review_disposition,
            {{ adapter.quote("EXECUTECALCFLAG") }} as is_execute_calc,
            {{ adapter.quote("PROMOTERESULTSFLAG") }} as is_promote_results,
            {{ adapter.quote("CREATECHILDSAMPLEFLAG") }} as is_create_child_sample,
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
            array_method_id::text as array_method_id,
            array_method_version_id::text as array_method_version_id,
            array_method_instance::integer as array_method_instance,
            array_method_item_status::text as array_method_item_status,
            instrument_id::text as instrument_id,
            instrument_type_id::text as instrument_type_id,
            sample_type_id::text as sample_type_id,
            review_disposition::text as review_disposition,
            is_execute_calc::boolean as is_execute_calc,
            is_promote_results::boolean as is_promote_results,
            is_create_child_sample::boolean as is_create_child_sample,
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
