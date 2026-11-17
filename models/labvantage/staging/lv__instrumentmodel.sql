{% set src = source("labvantage", "instrumentmodel") %}

with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("MODDT") }} as modified_at,
            {{ adapter.quote("TRACELOGID") }} as trace_log_id,
            {{ adapter.quote("AUDITSEQUENCE") }} as audit_sequence,
            {{ adapter.quote("NOTES") }} as notes,
            {{ adapter.quote("UNMANAGEDFLAG") }} as unmanaged_flag,
            {{ adapter.quote("INSTRUMENTMODELID") }} as instrument_model_id,
            {{ adapter.quote("INSTRUMENTPROTOCOLPROVIDERID") }}
            as instrument_protocol_provider_id,
            {{ adapter.quote("MODBY") }} as modified_by,
            {{ adapter.quote("CREATEDT") }} as created_at,
            {{ adapter.quote("TIMEOUT") }} as timeout,
            {{ adapter.quote("ACTIVEFLAG") }} as is_active,
            {{ adapter.quote("MODTOOL") }} as modified_tool,
            {{ adapter.quote("CREATEBY") }} as created_by,
            {{ adapter.quote("INSTRUMENTMODELDESC") }} as instrument_model_desc,
            {{ adapter.quote("INSTRUMENTTYPEID") }} as instrument_type_id,
            {{ adapter.quote("USERSEQUENCE") }} as user_sequence,
            {{ adapter.quote("TEMPLATEFLAG") }} as is_template,
            {{ adapter.quote("CREATETOOL") }} as created_tool,
            {{ airbyte_get_emit_col(src) }} as elt_emitted_at,
            {{ airbyte_get_id_col(src) }} as elt_hash_id
        from source
    ),
    typed as (
        select
            {{ cast_timestamp_tz("modified_at", "UTC") }},
            trace_log_id::text as trace_log_id,
            audit_sequence::integer as audit_sequence,
            notes::text as notes,
            unmanaged_flag::text as unmanaged_flag,
            instrument_model_id::text as instrument_model_id,
            instrument_protocol_provider_id::text as instrument_protocol_provider_id,
            modified_by::text as modified_by,
            {{ cast_timestamp_tz("created_at", "UTC") }},
            timeout::float as timeout,
            iff(is_active = 'Y', true, false) as is_active,
            modified_tool::text as modified_tool,
            created_by::text as created_by,
            instrument_model_desc::text as instrument_model_desc,
            instrument_type_id::text as instrument_type_id,
            user_sequence::integer as user_sequence,
            iff(is_template = 'Y', true, false) as is_template,
            created_tool::text as created_tool,
            elt_emitted_at::timestamp_tz as elt_emitted_at,
            elt_hash_id::text as elt_hash_id
        from renamed
    )

select *
from typed
