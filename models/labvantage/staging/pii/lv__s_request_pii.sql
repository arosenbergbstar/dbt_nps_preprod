{{ config(post_hook="{{ dbt_snow_mask.apply_masking_policy('models') }}") }}
{% set src = source("labvantage", "s_request") %}
{% set column_names = dbt_utils.get_filtered_columns_in_relation(from=src) %}
with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("U_TRFID") }} as trf_id,
            {{ adapter.quote("CDX_SUBJECTID") }} as subject_id,
            {{ adapter.quote("S_REQUESTID") }} as request_id,
            {{ adapter.quote("U_WORKITEMID") }} as work_item_id,
            {{ adapter.quote("STUDYID") }} as study_id,
            {{ adapter.quote("REQUESTSTATUS") }} as request_status,
            {{ adapter.quote("CREATEDT") }} as accessioned_at,
            {{ adapter.quote("U_DATESAMPLESRECEIVED") }} as samples_received_at,
            {{ adapter.quote("REQUESTDT") }} as physician_signature_date,
            {{ adapter.quote("U_PHYSSIG") }} as has_physician_signature,
            {{ adapter.quote("U_DATACOMPLETE") }} as has_complete_data,
            {{ adapter.quote("U_INSTITUTION") }} as institution,
            {{ adapter.quote("U_ARM") }} as study_arm,
            -- This is a flag that indicates if reporting is allowed for a study arm.
            -- Y – This request is for a study that has arms and is for an arm that
            -- has immediate reporting or reporting has been released.
            -- N – This request is for a study that has arms and is for an arm that
            -- has delayed reporting
            -- Null – This request is for a study that does not have arms.
            {{ adapter.quote("U_STUDYARMREPORTINGFLAG") }} as is_reporting_allowed,

            {{ adapter.quote("U_SHIPPER") }} as shipper,
            {{ adapter.quote("U_TRACKINGNUMBER") }} as shipper_tracking_number,
            {{ adapter.quote("U_ORDERINGPHYSICIAN") }} as ordering_physician_id,
            {{ adapter.quote("U_ORDERINGPHYSICIANNAME") }} as ordering_physician_name,
            {{ adapter.quote("U_ORDERINGPHYSICIANTYPE") }} as ordering_physician_type,
            {{ adapter.quote("U_ADDREPORTRECIPIENT") }} as additional_report_recipient,
            {{ adapter.quote("REVIEWDISPOSITION") }} as review_disposition,

            {{ adapter.quote("U_WORKITEMVERSIONID") }} as work_item_version_id,
            {{ adapter.quote("PURPOSE") }} as purpose,
            {{ adapter.quote("CDX_NOOFSAMPLESEXPECTED") }} as num_samples_expected,
            {{ adapter.quote("PRIORITY") }} as priority,

            {{ adapter.quote("NOTES") }} as notes,
            {{ adapter.quote("USERSEQUENCE") }} as user_sequence,
            {{ adapter.quote("AUDITSEQUENCE") }} as audit_sequence,
            {{ adapter.quote("TEMPLATEFLAG") }} as is_from_template,
            {{ adapter.quote("ACTIVEFLAG") }} as is_active,
            {{ adapter.quote("AUTORELEASEFLAG") }} as is_auto_release,
            {{ adapter.quote("TRACELOGID") }} as trace_log_id,
            {{ adapter.quote("CREATIONRULE") }} as creation_rule,
            {{ adapter.quote("REQUESTCLASS") }} as request_class,

            {{ adapter.quote("DUEDT") }} as due_at,
            {{ adapter.quote("ACCEPTEDDT") }} as accepted_at,
            {{ adapter.quote("RELEASEDDT") }} as released_at,
            {{ adapter.quote("REQUESTDT") }} as requested_at,
            {{ adapter.quote("MODBY") }} as modified_by,
            {{ adapter.quote("MODDT") }} as modified_at,
            {{ adapter.quote("CREATEBY") }} as created_by,
            {{ adapter.quote("CREATEDT") }} as created_at,
            {{ adapter.quote("CANCELLEDBY") }} as cancelled_by,
            {{ adapter.quote("CANCELLEDDT") }} as cancelled_at,
            {{ adapter.quote("COMPLETEDDT") }} as completed_at,
            {{ adapter.quote("RECEIVEDDT") }} as received_at,
            {{ adapter.quote("U_DATA_UPLOAD_AT") }} as data_upload_at,
            {{ adapter.quote("HOLDBY") }} as hold_by,
            {{ adapter.quote("HOLDDT") }} as hold_at,
            {{ adapter.quote("STARTEDDT") }} as started_at,
            {{ airbyte_get_emit_col(src) }} as elt_emitted_at,
            {{ airbyte_get_id_col(src) }} as elt_hash_id

        from source
    ),
    typed as (
        select
            trf_id::text as trf_id,
            subject_id::text as subject_id,
            request_id::text as request_id,
            work_item_id::text as work_item_id,
            study_id::text as study_id,
            request_status::text as request_status,
            {{ cast_timestamp_tz("accessioned_at", "UTC") }},
            {{ cast_timestamp_tz("samples_received_at", "UTC") }},
            {{ cast_timestamp_tz("physician_signature_date", "UTC") }},

            coalesce(
                iff(has_physician_signature = 'T', true, false),
                iff(physician_signature_date is null, false, true)
            ) as has_physician_signature,
            iff(has_complete_data = 'T', true, false) as has_complete_data,
            institution,
            study_arm,
            iff(is_reporting_allowed = 'Y', true, false) as is_reporting_allowed,
            shipper::text as shipper,
            shipper_tracking_number::text as shipper_tracking_number,
            ordering_physician_id::text as ordering_physician_id,
            ordering_physician_name::text as ordering_physician_name,
            ordering_physician_type::text as ordering_physician_type,
            additional_report_recipient::text as additional_report_recipient,
            review_disposition::text as review_disposition,

            work_item_version_id::text as work_item_version_id,
            purpose::text as purpose,
            num_samples_expected::integer as num_samples_expected,
            priority::text as priority,

            notes::text as notes,
            user_sequence::integer as user_sequence,
            audit_sequence::integer as audit_sequence,
            is_from_template::boolean as is_from_template,
            is_active::boolean as is_active,
            is_auto_release::boolean as is_auto_release,
            trace_log_id::text as trace_log_id,
            creation_rule::text as creation_rule,
            request_class::text as request_class,

            {{ cast_timestamp_tz("due_at", "UTC") }},
            {{ cast_timestamp_tz("accepted_at", "UTC") }},
            {{ cast_timestamp_tz("released_at", "UTC") }},
            {{ cast_timestamp_tz("requested_at", "UTC") }},
            {{ cast_timestamp_tz("completed_at", "UTC") }},
            {{ cast_timestamp_tz("received_at", "UTC") }},
            {{ cast_timestamp_tz("data_upload_at", "UTC") }},
            hold_by::text as hold_by,
            {{ cast_timestamp_tz("hold_at", "UTC") }},
            {{ cast_timestamp_tz("started_at", "UTC") }},
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
