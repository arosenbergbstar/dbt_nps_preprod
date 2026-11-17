{% set src = source("labvantage", "taskexecitem") %}

with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("MODDT") }} as modified_at,
            {{ adapter.quote("TRACELOGID") }} as trace_log_id,
            {{ adapter.quote("AUDITSEQUENCE") }} as audit_sequence,
            {{ adapter.quote("FROMTASKEXECID") }} as from_task_exec_id,
            {{ adapter.quote("WORKFLOWEXECID") }} as workflow_exec_id,
            {{ adapter.quote("TASKDEFITEMID") }} as task_def_item_id,
            {{ adapter.quote("ITEMSDCID") }} as item_sdc_id,
            {{ adapter.quote("MODBY") }} as modified_by,
            {{ adapter.quote("TASKEXECID") }} as task_exec_id,
            {{ adapter.quote("CREATEDT") }} as created_at,
            {{ adapter.quote("TOTASKEXECID") }} as to_task_exec_id,
            {{ adapter.quote("IOID") }} as io_id,
            {{ adapter.quote("MODTOOL") }} as modified_tool,
            {{ adapter.quote("CREATEBY") }} as created_by,
            {{ adapter.quote("ITEMKEYID3") }} as item_key_id_3,
            {{ adapter.quote("TASKDEFID") }} as task_def_id,
            {{ adapter.quote("ITEMKEYID1") }} as item_key_id_1,
            {{ adapter.quote("ITEMKEYID2") }} as item_key_id_2,
            {{ adapter.quote("TASKDEFVERSIONID") }} as task_def_version_id,
            {{ adapter.quote("TASKQUEUEID") }} as task_queue_id,
            {{ adapter.quote("USERSEQUENCE") }} as user_sequence,
            {{ adapter.quote("TYPEFLAG") }} as type_flag,
            {{ adapter.quote("TASKDEFVARIANTID") }} as task_def_variant_id,
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
            from_task_exec_id::text as from_task_exec_id,
            workflow_exec_id::text as workflow_exec_id,
            task_def_item_id::text as task_def_item_id,
            item_sdc_id::text as item_sdc_id,
            modified_by::text as modified_by,
            task_exec_id::text as task_exec_id,
            {{ cast_timestamp_tz("created_at", "UTC") }},
            to_task_exec_id::text as to_task_exec_id,
            io_id::text as io_id,
            modified_tool::text as modified_tool,
            created_by::text as created_by,
            item_key_id_3::text as item_key_id_3,
            task_def_id::text as task_def_id,
            item_key_id_1::text as item_key_id_1,
            item_key_id_2::text as item_key_id_2,
            task_def_version_id::text as task_def_version_id,
            task_queue_id::text as task_queue_id,
            user_sequence::integer as user_sequence,
            type_flag::text as type_flag,
            task_def_variant_id::text as task_def_variant_id,
            created_tool::text as created_tool,
            elt_emitted_at::timestamp_tz as elt_emitted_at,
            elt_hash_id::text as elt_hash_id
        from renamed
    )

select *
from typed
