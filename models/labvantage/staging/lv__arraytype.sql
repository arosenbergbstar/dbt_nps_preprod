{% set src = source("labvantage", "arraytype") %}

with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("VERSIONAPPROVEDDT") }} as version_approved_at,
            {{ adapter.quote("NOTES") }} as notes,
            {{ adapter.quote("NUMCOLUMNS") }} as num_columns,
            {{ adapter.quote("CREATEDT") }} as created_at,
            {{ adapter.quote("VERTICALLABELTYPE") }} as vertical_label_type,
            {{ adapter.quote("CREATEBY") }} as created_by,
            {{ adapter.quote("NUMROWS") }} as num_rows,
            {{ adapter.quote("HORIZONTALLABELDIRECTION") }}
            as horizontal_label_direction,
            {{ adapter.quote("ARRAYTYPEVERSIONID") }} as array_type_version_id,
            {{ adapter.quote("ARRAYTYPEDESC") }} as array_type_desc,
            {{ adapter.quote("MAXVOLUMEUNITS") }} as max_volume_units,
            {{ adapter.quote("USERSEQUENCE") }} as user_sequence,
            {{ adapter.quote("MODDT") }} as modified_at,
            {{ adapter.quote("TRACELOGID") }} as trace_log_id,
            {{ adapter.quote("AUDITSEQUENCE") }} as audit_sequence,
            {{ adapter.quote("ARRAYTYPEID") }} as array_type_id,
            {{ adapter.quote("VERSIONEFFECTIVEDT") }} as version_effective_at,
            {{ adapter.quote("MODBY") }} as modified_by,
            {{ adapter.quote("CLASSIFICATION") }} as classification,
            {{ adapter.quote("VERTICALLABELDIRECTION") }} as vertical_label_direction,
            {{ adapter.quote("ACTIVEFLAG") }} as is_active,
            {{ adapter.quote("MODTOOL") }} as modified_tool,
            {{ adapter.quote("MAXVOLUME") }} as max_volume,
            {{ adapter.quote("VERSIONSTATUS") }} as version_status,
            {{ adapter.quote("HORIZONTALLABELSTART") }} as horizontal_label_start,
            {{ adapter.quote("HORIZONTALLABELTYPE") }} as horizontal_label_type,
            {{ adapter.quote("ASLFLAG") }} as asl_flag,
            {{ adapter.quote("TEMPLATEFLAG") }} as is_template,
            {{ adapter.quote("VERTICALLABELSTART") }} as vertical_label_start,
            {{ adapter.quote("CREATETOOL") }} as created_tool,
            {{ airbyte_get_emit_col(src) }} as elt_emitted_at,
            {{ airbyte_get_id_col(src) }} as elt_hash_id
        from source
    ),
    typed as (
        select
            {{ cast_timestamp_tz("version_approved_at", "UTC") }},
            notes::text as notes,
            num_columns::integer as num_columns,
            {{ cast_timestamp_tz("created_at", "UTC") }},
            vertical_label_type::text as vertical_label_type,
            created_by::text as created_by,
            num_rows::integer as num_rows,
            horizontal_label_direction::text as horizontal_label_direction,
            array_type_version_id::text as array_type_version_id,
            array_type_desc::text as array_type_desc,
            max_volume_units::text as max_volume_units,
            user_sequence::integer as user_sequence,
            {{ cast_timestamp_tz("modified_at", "UTC") }},
            trace_log_id::text as trace_log_id,
            audit_sequence::integer as audit_sequence,
            array_type_id::text as array_type_id,
            {{ cast_timestamp_tz("version_effective_at", "UTC") }},
            modified_by::text as modified_by,
            classification::text as classification,
            vertical_label_direction::text as vertical_label_direction,
            iff(is_active = 'Y', true, false) as is_active,
            modified_tool::text as modified_tool,
            max_volume::float as max_volume,
            version_status::text as version_status,
            horizontal_label_start::text as horizontal_label_start,
            horizontal_label_type::text as horizontal_label_type,
            asl_flag::text as asl_flag,
            iff(is_template = 'Y', true, false) as is_template,
            vertical_label_start::text as vertical_label_start,
            created_tool::text as created_tool,
            elt_emitted_at::timestamp_tz as elt_emitted_at,
            elt_hash_id::text as elt_hash_id
        from renamed
    )

select *
from typed
