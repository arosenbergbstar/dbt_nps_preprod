{% set src = source("labvantage", "a_arrayarraymethoditem") %}

with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("MODDT") }} as modified_at,
            {{ adapter.quote("TRACELOGID") }} as trace_log_id,
            {{ adapter.quote("EXECUTECALCFLAG") }} as is_execute_calc,
            {{ adapter.quote("AUDITSEQUENCE") }} as audit_sequence,
            {{ adapter.quote("INSTRUMENTID") }} as instrument_id,
            {{ adapter.quote("REVIEWDISPOSITION") }} as review_disposition,
            {{ adapter.quote("MODBY") }} as modified_by,
            {{ adapter.quote("ARRAYID") }} as array_id,
            {{ adapter.quote("CREATEDT") }} as created_at,
            {{ adapter.quote("ARRAYMETHODID") }} as array_method_id,
            {{ adapter.quote("ARRAYMETHODVERSIONID") }} as array_method_version_id,
            {{ adapter.quote("CREATECHILDSAMPLEFLAG") }} as is_create_child_sample,
            {{ adapter.quote("AUDITOPFLAG") }} as audit_op_flag,
            {{ adapter.quote("SAMPLETYPEID") }} as sample_type_id,
            {{ adapter.quote("PROMOTERESULTSFLAG") }} as is_promote_results,
            {{ adapter.quote("MODTOOL") }} as modified_tool,
            {{ adapter.quote("CREATEBY") }} as created_by,
            {{ adapter.quote("ARRAYMETHODINSTANCE") }} as array_method_instance,
            {{ adapter.quote("ARRAYMETHODITEMSTATUS") }} as array_method_item_status,
            {{ adapter.quote("INSTRUMENTTYPEID") }} as instrument_type_id,
            {{ adapter.quote("USERSEQUENCE") }} as user_sequence,
            {{ adapter.quote("CREATETOOL") }} as created_tool,
            {{ airbyte_get_emit_col(src) }} as elt_emitted_at,
            {{ airbyte_get_id_col(src) }} as elt_hash_id
        from source
    ),
    typed as (
        select
            {{ cast_timestamp_tz("modified_at", "UTC") }},
            trace_log_id::text as trace_log_id,
            iff(is_execute_calc = 'Y', true, false) as is_execute_calc,
            audit_sequence::integer as audit_sequence,
            instrument_id::text as instrument_id,
            review_disposition::text as review_disposition,
            modified_by::text as modified_by,
            array_id::text as array_id,
            {{ cast_timestamp_tz("created_at", "UTC") }},
            array_method_id::text as array_method_id,
            array_method_version_id::text as array_method_version_id,
            iff(is_create_child_sample = 'Y', true, false) as is_create_child_sample,
            audit_op_flag::text as audit_op_flag,
            sample_type_id::text as sample_type_id,
            iff(is_promote_results = 'Y', true, false) as is_promote_results,
            modified_tool::text as modified_tool,
            created_by::text as created_by,
            array_method_instance::integer as array_method_instance,
            array_method_item_status::text as array_method_item_status,
            instrument_type_id::text as instrument_type_id,
            user_sequence::integer as user_sequence,
            created_tool::text as created_tool,
            elt_emitted_at::timestamp_tz as elt_emitted_at,
            elt_hash_id::text as elt_hash_id
        from renamed
    )

select *
from typed
