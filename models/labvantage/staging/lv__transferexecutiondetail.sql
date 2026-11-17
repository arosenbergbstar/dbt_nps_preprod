{% set src = source("labvantage", "transferexecutiondetail") %}

with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("MODDT") }} as modified_at,
            {{ adapter.quote("TRACELOGID") }} as trace_log_id,
            {{ adapter.quote("TARGETKEYID3") }} as target_key_id_3,
            {{ adapter.quote("TARGETKEYID2") }} as target_key_id_2,
            {{ adapter.quote("AUDITSEQUENCE") }} as audit_sequence,
            {{ adapter.quote("TARGETKEYID1") }} as target_key_id_1,
            {{ adapter.quote("MODBY") }} as modified_by,
            {{ adapter.quote("CREATEDT") }} as created_at,
            {{ adapter.quote("TARGETSDCID") }} as target_sdc_id,
            {{ adapter.quote("MODTOOL") }} as modified_tool,
            {{ adapter.quote("CREATEBY") }} as created_by,
            {{ adapter.quote("SOURCESDCID") }} as source_sdc_id,
            {{ adapter.quote("SOURCEKEYID2") }} as source_key_id_2,
            {{ adapter.quote("SOURCEKEYID1") }} as source_key_id_1,
            {{ adapter.quote("USERSEQUENCE") }} as user_sequence,
            {{ adapter.quote("TRANSFEREXECUTIONID") }} as transfer_execution_id,
            {{ adapter.quote("SOURCEKEYID3") }} as source_key_id_3,
            {{ adapter.quote("TRANSFEREXECUTIONDETAILID") }}
            as transfer_execution_detail_id,
            {{ adapter.quote("CREATETOOL") }} as created_tool,
            {{ airbyte_get_emit_col(src) }} as elt_emitted_at,
            {{ airbyte_get_id_col(src) }} as elt_hash_id
        from source
    ),
    typed as (
        select
            {{ cast_timestamp_tz("modified_at", "UTC") }},
            trace_log_id::text as trace_log_id,
            target_key_id_3::text as target_key_id_3,
            target_key_id_2::text as target_key_id_2,
            audit_sequence::integer as audit_sequence,
            target_key_id_1::text as target_key_id_1,
            modified_by::text as modified_by,
            {{ cast_timestamp_tz("created_at", "UTC") }},
            target_sdc_id::text as target_sdc_id,
            modified_tool::text as modified_tool,
            created_by::text as created_by,
            source_sdc_id::text as source_sdc_id,
            source_key_id_2::text as source_key_id_2,
            source_key_id_1::text as source_key_id_1,
            user_sequence::integer as user_sequence,
            transfer_execution_id::text as transfer_execution_id,
            source_key_id_3::text as source_key_id_3,
            transfer_execution_detail_id::text as transfer_execution_detail_id,
            created_tool::text as created_tool,
            elt_emitted_at::timestamp_tz as elt_emitted_at,
            elt_hash_id::text as elt_hash_id
        from renamed
    )

select *
from typed
