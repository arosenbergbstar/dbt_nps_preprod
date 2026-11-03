{# Renamed and typed LabVantage sdiapprovalstep table, following the dbt_base lv__ pattern. #}
{% set src = source("labvantage", "sdiapprovalstep") %}

with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("SDCID") }} as sdc_id,
            {{ adapter.quote("KEYID1") }} as key_id_1,
            {{ adapter.quote("KEYID2") }} as key_id_2,
            {{ adapter.quote("KEYID3") }} as key_id_3,
            {{ adapter.quote("APPROVALTYPEID") }} as approval_type_id,
            {{ adapter.quote("APPROVALSTEP") }} as approval_step,
            {{ adapter.quote("APPROVALSTEPINSTANCE") }} as approval_step_instance,
            {{ adapter.quote("APPROVALFLAG") }} as approval_flag,
            {{ adapter.quote("ROLEID") }} as role_id,
            {{ adapter.quote("ASSIGNEDTO") }} as assigned_to,
            {{ adapter.quote("REVIEWEDBY") }} as reviewed_by,
            {{ adapter.quote("REVIEWEDDT") }} as reviewed_at,
            {{ adapter.quote("NOTES") }} as notes,
            {{ adapter.quote("FORCEPEERFLAG") }} as is_force_peer,
            {{ adapter.quote("MANDATORYFLAG") }} as is_mandatory,
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
            sdc_id::text as sdc_id,
            key_id_1::text as key_id_1,
            key_id_2::text as key_id_2,
            key_id_3::text as key_id_3,
            approval_type_id::text as approval_type_id,
            approval_step::text as approval_step,
            approval_step_instance::integer as approval_step_instance,
            approval_flag::text as approval_flag,
            role_id::text as role_id,
            assigned_to::text as assigned_to,
            reviewed_by::text as reviewed_by,
            {{ cast_timestamp_tz("reviewed_at", "UTC") }},
            notes::text as notes,
            is_force_peer::boolean as is_force_peer,
            is_mandatory::boolean as is_mandatory,
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
