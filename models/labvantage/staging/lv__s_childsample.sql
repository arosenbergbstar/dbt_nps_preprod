{% set src = source("labvantage", "s_childsample") %}

with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("MODDT") }} as modified_at,
            {{ adapter.quote("TRACELOGID") }} as trace_log_id,
            {{ adapter.quote("AUDITSEQUENCE") }} as audit_sequence,
            {{ adapter.quote("CHILDSAMPLEPLANID") }} as child_sample_plan_id,
            {{ adapter.quote("MODBY") }} as modified_by,
            {{ adapter.quote("CREATEDT") }} as created_at,
            {{ adapter.quote("S_CHILDSAMPLEID") }} as child_sample_id,
            {{ adapter.quote("MODTOOL") }} as modified_tool,
            {{ adapter.quote("CREATEBY") }} as created_by,
            {{ adapter.quote("S_SAMPLEID") }} as sample_id,
            {{ adapter.quote("CHILDSAMPLEPLANVERSIONID") }}
            as child_sample_plan_version_id,
            {{ adapter.quote("CHILDSAMPLEPLANITEMID") }} as child_sample_plan_item_id,
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
            audit_sequence::integer as audit_sequence,
            child_sample_plan_id::text as child_sample_plan_id,
            modified_by::text as modified_by,
            {{ cast_timestamp_tz("created_at", "UTC") }},
            child_sample_id::text as child_sample_id,
            modified_tool::text as modified_tool,
            created_by::text as created_by,
            sample_id::text as sample_id,
            child_sample_plan_version_id::text as child_sample_plan_version_id,
            child_sample_plan_item_id::text as child_sample_plan_item_id,
            user_sequence::integer as user_sequence,
            created_tool::text as created_tool,
            elt_emitted_at::timestamp_tz as elt_emitted_at,
            elt_hash_id::text as elt_hash_id
        from renamed
    )

select *
from typed
