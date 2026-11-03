{% set src = source("labvantage", "s_studysite") %}
with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("S_STUDYSITEID") }} as study_site_id,
            {{ adapter.quote("STUDYSITEDESC") }} as study_site_description,
            {{ adapter.quote("SSTUDYID") }} as study_id,
            {{ adapter.quote("CLINICALPROTOCOLID") }} as clinical_protocol_id,

            {{ adapter.quote("CLINICALPROTOCOLREVISION") }} clinical_protocol_revision,
            {{ adapter.quote("CLINICALPROTOCOLVERSIONID") }}
            as clinical_protocol_version_id,
            {{ adapter.quote("DEPARTMENTID") }} as department_id,
            {{ adapter.quote("PLANNEDPARTICIPANTS") }} planned_participants,
            {{ adapter.quote("SAMPLERECEIPTGRACEPERIOD") }} sample_receipt_grace_period,
            {{ adapter.quote("SAMPLERECEIPTGRACEPERIODUNITS") }}
            as sample_receipt_grace_period_units,

            {{ adapter.quote("NOTES") }} as notes,
            {{ adapter.quote("USERSEQUENCE") }} as user_sequence,
            {{ adapter.quote("AUDITSEQUENCE") }} as audit_sequence,
            {{ adapter.quote("TEMPLATEFLAG") }} as is_from_template,
            {{ adapter.quote("ACTIVEFLAG") }} as is_active,
            {{ adapter.quote("TRACELOGID") }} as trace_log_id,

            {{ adapter.quote("INITIATEDDT") }} as initiated_at,
            {{ adapter.quote("CLOSEDDT") }} as closed_at,
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
            study_site_id::text as study_site_id,
            study_site_description::text as study_site_description,
            study_id::text as study_id,
            clinical_protocol_id::text as clinical_protocol_id,

            clinical_protocol_revision::text as clinical_protocol_revision,
            clinical_protocol_version_id::text as clinical_protocol_version_id,
            department_id::text as department_id,
            planned_participants::text as planned_participants,
            sample_receipt_grace_period::text as sample_receipt_grace_period,
            sample_receipt_grace_period_units::text
            as sample_receipt_grace_period_units,

            notes::text as notes,
            user_sequence::integer as user_sequence,
            audit_sequence::integer as audit_sequence,
            is_from_template::boolean as is_from_template,
            is_active::boolean as is_active,
            trace_log_id::text as trace_log_id,

            {{ cast_timestamp_tz("initiated_at", "UTC") }},
            {{ cast_timestamp_tz("closed_at", "UTC") }},
            modified_by::text as modified_by,
            {{ cast_timestamp_tz("modified_at", "UTC") }},
            created_by::text as created_by,
            {{ cast_timestamp_tz("created_at", "UTC") }},

            elt_emitted_at::text as elt_emitted_at,
            elt_hash_id::text as elt_hash_id
        from renamed
    )
select *
from typed
