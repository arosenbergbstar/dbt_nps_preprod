{{ config(post_hook="{{ dbt_snow_mask.apply_masking_policy('models') }}") }}
{% set src = source("labvantage", "s_samplefamily") %}
with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("S_SAMPLEFAMILYID") }} as sample_family_id,
            {{ adapter.quote("U_REQUESTID") }} as request_id,
            {{ adapter.quote("PARTICIPANTID") }} as participant_id,
            {{ adapter.quote("SSTUDYID") }} as study_id,
            {{ adapter.quote("SAMPLETYPEID") }} as sample_type_id,
            {{ adapter.quote("SUBJECTID") }} as subject_id,
            {{ adapter.quote("STUDYSITEID") }} as study_site_id,
            {{ adapter.quote("COLLECTMETHODID") }} as collection_method_id,

            {{ adapter.quote("U_SHIPPER") }} as shipper,
            {{ adapter.quote("INITIALVOLUME") }} as initial_volume,
            {{ adapter.quote("INITIALVOLUMEUNITS") }} as initial_volume_units,
            {{ adapter.quote("INITIALMASS") }} as initial_mass,
            {{ adapter.quote("INITIALMASSUNITS") }} as initial_mass_units,

            {{ adapter.quote("CLINICALPROTOCOLREVISION") }}
            as clinical_protocol_revision,
            {{ adapter.quote("CLINICALEVENT") }} as clinical_event,
            {{ adapter.quote("KITTRACKITEM") }} as kit_track_item,
            {{ adapter.quote("ANIMAL") }} as animal,
            {{ adapter.quote("CONDITIONALAPPROVALREASON") }}
            as conditional_approval_reason,
            {{ adapter.quote("DEVIATIONDESC") }} as deviation_description,
            {{ adapter.quote("CONDITIONALAPPROVALFLAG") }} as has_conditional_approval,
            {{ adapter.quote("LATERALITY") }} as laterality,
            {{ adapter.quote("U_TRACKINGNUMBER") }} as tracking_number,
            {{ adapter.quote("TISSUECLASS") }} as tissue_class,
            {{ adapter.quote("COCFLAG") }} as coc_flag,
            {{ adapter.quote("EXTERNALSUBJECT") }} as external_subject,

            {{ adapter.quote("NOTES") }} as notes,
            {{ adapter.quote("USERSEQUENCE") }} as user_sequence,
            {{ adapter.quote("AUDITSEQUENCE") }} as audit_sequence,
            {{ adapter.quote("TEMPLATEFLAG") }} as is_from_template,
            {{ adapter.quote("ACTIVEFLAG") }} as is_active,
            {{ adapter.quote("TRACELOGID") }} as trace_log_id,
            {{ adapter.quote("SAMPLEFAMILYDESC") }} as sample_family_description,
            {{ adapter.quote("RESTRICTIONSFLAG") }} as is_restricted,

            {{ adapter.quote("COLLECTIONDT") }} as samples_collected_at,
            {{ adapter.quote("RECIEVEDDT") }} as received_at,
            {{ adapter.quote("VERIFIEDBY") }} as verified_by,
            {{ adapter.quote("VERIFIEDDT") }} as verified_at,
            {{ adapter.quote("APPROVEDBY") }} as approved_by,
            {{ adapter.quote("APPROVEDDT") }} as approved_at,
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
            sample_family_id::text as sample_family_id,
            request_id::text as request_id,
            participant_id::text as participant_id,
            study_id::text as study_id,
            sample_type_id::text as sample_type_id,
            subject_id::text as subject_id,
            study_site_id::text as study_site_id,
            collection_method_id::text as collection_method_id,

            shipper::text as shipper,
            initial_volume::numeric(38, 10) as initial_volume,
            initial_volume_units::text as initial_volume_units,
            initial_mass::numeric(38, 10) as initial_mass,
            initial_mass_units::text as initial_mass_units,

            clinical_protocol_revision::text as clinical_protocol_revision,
            clinical_event::text as clinical_event,
            kit_track_item::text as kit_track_item,
            deviation_description::text as deviation_description,
            conditional_approval_reason::text as conditional_approval_reason,
            has_conditional_approval::boolean as has_conditional_approval,
            laterality::text as laterality,
            tracking_number::text as tracking_number,
            tissue_class::text as tissue_class,
            external_subject::text as external_subject,

            notes::text as notes,
            user_sequence::integer as user_sequence,
            audit_sequence::integer as audit_sequence,
            is_from_template::boolean as is_from_template,
            is_active::boolean as is_active,
            trace_log_id::text as trace_log_id,
            sample_family_description::text as sample_family_description,
            is_restricted::boolean as is_restricted,

            {{ cast_timestamp_tz("samples_collected_at", "UTC") }},
            {{ cast_timestamp_tz("received_at", "UTC") }},
            verified_by::text as verified_by,
            {{ cast_timestamp_tz("verified_at", "UTC") }},
            approved_by::text as approved_by,
            {{ cast_timestamp_tz("approved_at", "UTC") }},
            modified_by::text as modified_by,
            {{ cast_timestamp_tz("modified_at", "UTC") }},

            elt_emitted_at::timestamp_tz as elt_emitted_at,
            elt_hash_id::text as elt_hash_id
        from renamed
    )
select *
from typed
