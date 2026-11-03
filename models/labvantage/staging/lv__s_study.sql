{% set src = source("labvantage", "s_study") %}
with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("S_STUDYID") }} as study_id,
            {{ adapter.quote("STUDYTYPE") }} as study_type,
            {{ adapter.quote("U_PATIENTREPORTTYPE") }} as patient_report_type,
            {{ adapter.quote("PROTOCOLNAME") }} as protocol_name,

            {{ adapter.quote("ESTIMATEDSAMPLES") }} as estimated_samples,
            {{ adapter.quote("STUDYFOCUS") }} as study_focus,
            {{ adapter.quote("PRIMARYAFFECTION") }} as primary_affection,
            {{ adapter.quote("VERIFIEDBY") }} as verified_by,
            {{ adapter.quote("VERIFIEDBYROLE") }} as verified_by_role,
            {{ adapter.quote("STUDYDESC") }} as study_description,
            {{ adapter.quote("STUDYSTATUS") }} as study_status,
            {{ adapter.quote("PRIORITY") }} as priority,
            {{ adapter.quote("COLLECTINFOREQUIREDFLAG") }} as is_required_collect_info,
            {{ adapter.quote("PLANNEDPARTICIPANTS") }} as planned_participants,
            {{ adapter.quote("HIPAAFLAG") }} as is_hipaa,
            {{ adapter.quote("DEFAULTGLPFLAG") }} as is_default_glp,
            {{ adapter.quote("PLANNEDSITES") }} as planned_sites,
            {{ adapter.quote("STUDYALIAS") }} as study_alias,
            {{ adapter.quote("DEPARTMENTID") }} as department_id,
            {{ adapter.quote("PROJECTID") }} as project_id,
            {{ adapter.quote("SITEDEPARTMENTID") }} as site_department_id,

            {{ adapter.quote("NOTES") }} as notes,
            {{ adapter.quote("USERSEQUENCE") }} as user_sequence,
            {{ adapter.quote("AUDITSEQUENCE") }} as audit_sequence,
            {{ adapter.quote("TEMPLATEFLAG") }} as is_from_template,
            {{ adapter.quote("ACTIVEFLAG") }} as is_active,
            {{ adapter.quote("TRACELOGID") }} as trace_log_id,

            {{ adapter.quote("COLLECTIONSTARTDT") }} as collection_started_at,
            {{ adapter.quote("COLLECTIONENDDT") }} as collection_ended_at,
            {{ adapter.quote("PROPOSEDSTARTDT") }} as proposed_start_at,
            {{ adapter.quote("PROPOSEDENDDT") }} as proposed_end_at,
            {{ adapter.quote("STARTDT") }} as started_at,
            {{ adapter.quote("COMPLETEDDT") }} as completed_at,
            {{ adapter.quote("ENDDT") }} as ended_at,

            {{ adapter.quote("CANCELLEDBY") }} as cancelled_by,
            {{ adapter.quote("CANCELLEDDT") }} as cancelled_at,
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
            study_id::text as study_id,
            study_type::text as study_type,
            patient_report_type::text as patient_report_type,
            study_description::text as study_description,
            study_status::text as study_status,

            department_id::text as department_id,
            project_id::text as project_id,
            site_department_id::text as site_department_id,
            protocol_name::text as protocol_name,
            primary_affection::text as primary_affection,
            priority::text as priority,
            is_required_collect_info::boolean as is_required_collect_info,
            planned_participants::text as planned_participants,
            is_hipaa::boolean as is_hipaa,
            is_default_glp::boolean as is_default_glp,
            planned_sites::text as planned_sites,
            study_alias::text as study_alias,
            verified_by::text as verified_by,
            verified_by_role::text as verified_by_role,

            notes::text as notes,
            user_sequence::integer as user_sequence,
            audit_sequence::integer as audit_sequence,
            is_from_template::boolean as is_from_template,
            is_active::boolean as is_active,
            trace_log_id::text as trace_log_id,

            estimated_samples::text as estimated_samples,
            study_focus::text as study_focus,

            {{ cast_timestamp_tz("collection_started_at", "UTC") }},
            {{ cast_timestamp_tz("collection_ended_at", "UTC") }},
            {{ cast_timestamp_tz("proposed_start_at", "UTC") }},
            {{ cast_timestamp_tz("proposed_end_at", "UTC") }},
            {{ cast_timestamp_tz("started_at", "UTC") }},
            {{ cast_timestamp_tz("completed_at", "UTC") }},
            {{ cast_timestamp_tz("ended_at", "UTC") }},

            cancelled_by::text as cancelled_by,
            {{ cast_timestamp_tz("cancelled_at", "UTC") }},
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
