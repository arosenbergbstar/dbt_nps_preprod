{% set src = source("labvantage", "transferexecution") %}

with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("NOTES") }} as notes,
            {{ adapter.quote("TRANSFEREXECUTIONDESC") }} as transfer_execution_desc,
            {{ adapter.quote("CREATEDT") }} as created_at,
            {{ adapter.quote("ARRAYTRANSFERMETHODID") }} as array_transfer_method_id,
            {{ adapter.quote("CREATEBY") }} as created_by,
            {{ adapter.quote("ARRAYTRANSFERMETHODVERSIONID") }}
            as array_transfer_method_version_id,
            {{ adapter.quote("VOLUMEUNITS") }} as volume_units,
            {{ adapter.quote("USERSEQUENCE") }} as user_sequence,
            {{ adapter.quote("MODDT") }} as modified_at,
            {{ adapter.quote("TRACELOGID") }} as trace_log_id,
            {{ adapter.quote("AUDITSEQUENCE") }} as audit_sequence,
            {{ adapter.quote("MODBY") }} as modified_by,
            {{ adapter.quote("CONCENTRATION") }} as concentration,
            {{ adapter.quote("ACTIVEFLAG") }} as is_active,
            {{ adapter.quote("VOLUME") }} as volume,
            {{ adapter.quote("SAMPLETYPEID") }} as sample_type_id,
            {{ adapter.quote("MODTOOL") }} as modified_tool,
            {{ adapter.quote("TEMPLATESAMPLEID") }} as template_sample_id,
            {{ adapter.quote("TREATMENTTYPEID") }} as treatment_type_id,
            {{ adapter.quote("DEDUCTPARENTVOLUMEUNITS") }}
            as deduct_parent_volume_units,
            {{ adapter.quote("PREPTYPEID") }} as prep_type_id,
            {{ adapter.quote("CONCENTRATIONUNITS") }} as concentration_units,
            {{ adapter.quote("TRANSFEREXECUTIONID") }} as transfer_execution_id,
            {{ adapter.quote("TEMPLATEFLAG") }} as is_template,
            {{ adapter.quote("DEDUCTPARENTVOLUME") }} as deduct_parent_volume,
            {{ adapter.quote("CREATETOOL") }} as created_tool,
            {{ airbyte_get_emit_col(src) }} as elt_emitted_at,
            {{ airbyte_get_id_col(src) }} as elt_hash_id
        from source
    ),
    typed as (
        select
            notes::text as notes,
            transfer_execution_desc::text as transfer_execution_desc,
            {{ cast_timestamp_tz("created_at", "UTC") }},
            array_transfer_method_id::text as array_transfer_method_id,
            created_by::text as created_by,
            array_transfer_method_version_id::text as array_transfer_method_version_id,
            volume_units::text as volume_units,
            user_sequence::integer as user_sequence,
            {{ cast_timestamp_tz("modified_at", "UTC") }},
            trace_log_id::text as trace_log_id,
            audit_sequence::integer as audit_sequence,
            modified_by::text as modified_by,
            concentration::float as concentration,
            iff(is_active = 'Y', true, false) as is_active,
            volume::float as volume,
            sample_type_id::text as sample_type_id,
            modified_tool::text as modified_tool,
            template_sample_id::text as template_sample_id,
            treatment_type_id::text as treatment_type_id,
            deduct_parent_volume_units::text as deduct_parent_volume_units,
            prep_type_id::text as prep_type_id,
            concentration_units::text as concentration_units,
            transfer_execution_id::text as transfer_execution_id,
            iff(is_template = 'Y', true, false) as is_template,
            deduct_parent_volume::float as deduct_parent_volume,
            created_tool::text as created_tool,
            elt_emitted_at::timestamp_tz as elt_emitted_at,
            elt_hash_id::text as elt_hash_id
        from renamed
    )

select *
from typed
