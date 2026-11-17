{% set src = source("labvantage", "s_sampledetail") %}

with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("MODDT") }} as modified_at,
            {{ adapter.quote("DETAILTYPE") }} as detail_type,
            {{ adapter.quote("TRACELOGID") }} as trace_log_id,
            {{ adapter.quote("AUDITSEQUENCE") }} as audit_sequence,
            {{ adapter.quote("NOTES") }} as notes,
            {{ adapter.quote("DETAILKEYID3") }} as detail_key_id_3,
            {{ adapter.quote("DETAILKEYID2") }} as detail_key_id_2,
            {{ adapter.quote("DETAILKEYID1") }} as detail_key_id_1,
            {{ adapter.quote("MODBY") }} as modified_by,
            {{ adapter.quote("DETAILVALUE") }} as detail_value,
            {{ adapter.quote("CREATEDT") }} as created_at,
            {{ adapter.quote("S_SAMPLEDETAILID") }} as sample_detail_id,
            {{ adapter.quote("MODTOOL") }} as modified_tool,
            {{ adapter.quote("CREATEBY") }} as created_by,
            {{ adapter.quote("S_SAMPLEID") }} as sample_id,
            {{ adapter.quote("DETAILSDCID") }} as detail_sdc_id,
            {{ adapter.quote("USERSEQUENCE") }} as user_sequence,
            {{ adapter.quote("CREATETOOL") }} as created_tool,
            {{ airbyte_get_emit_col(src) }} as elt_emitted_at,
            {{ airbyte_get_id_col(src) }} as elt_hash_id
        from source
    ),
    typed as (
        select
            {{ cast_timestamp_tz("modified_at", "UTC") }},
            detail_type::text as detail_type,
            trace_log_id::text as trace_log_id,
            audit_sequence::integer as audit_sequence,
            notes::text as notes,
            detail_key_id_3::text as detail_key_id_3,
            detail_key_id_2::text as detail_key_id_2,
            detail_key_id_1::text as detail_key_id_1,
            modified_by::text as modified_by,
            detail_value::text as detail_value,
            {{ cast_timestamp_tz("created_at", "UTC") }},
            sample_detail_id::text as sample_detail_id,
            modified_tool::text as modified_tool,
            created_by::text as created_by,
            sample_id::text as sample_id,
            detail_sdc_id::text as detail_sdc_id,
            user_sequence::integer as user_sequence,
            created_tool::text as created_tool,
            elt_emitted_at::timestamp_tz as elt_emitted_at,
            elt_hash_id::text as elt_hash_id
        from renamed
    )

select *
from typed
