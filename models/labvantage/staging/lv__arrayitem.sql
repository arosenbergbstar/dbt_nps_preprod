{# Renamed and typed LabVantage arrayitem table, following the dbt_base lv__ pattern. #}
{% set src = source("labvantage", "arrayitem") %}

with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("ARRAYITEMID") }} as array_item_id,
            {{ adapter.quote("ARRAYID") }} as array_id,
            {{ adapter.quote("ARRAYITEMDESC") }} as array_item_desc,
            {{ adapter.quote("ITEMLABEL") }} as item_label,
            {{ adapter.quote("VERTICALLABEL") }} as vertical_label,
            {{ adapter.quote("HORIZONTALLABEL") }} as horizontal_label,
            {{ adapter.quote("XPOS") }} as x_pos,
            {{ adapter.quote("YPOS") }} as y_pos,
            {{ adapter.quote("TOTALVOLUME") }} as total_volume,
            {{ adapter.quote("TOTALVOLUMEUNITS") }} as total_volume_units,
            {{ adapter.quote("CONCENTRATION") }} as concentration,
            {{ adapter.quote("CONCENTRATIONUNITS") }} as concentration_units,
            {{ adapter.quote("NOTES") }} as notes,
            {{ adapter.quote("TEMPLATEFLAG") }} as is_template,
            {{ adapter.quote("ACTIVEFLAG") }} as is_active,
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
            array_item_id::text as array_item_id,
            array_id::text as array_id,
            array_item_desc::text as array_item_desc,
            item_label::text as item_label,
            vertical_label::text as vertical_label,
            horizontal_label::text as horizontal_label,
            x_pos::float as x_pos,
            y_pos::float as y_pos,
            total_volume::float as total_volume,
            total_volume_units::text as total_volume_units,
            concentration::float as concentration,
            concentration_units::text as concentration_units,
            notes::text as notes,
            is_template::boolean as is_template,
            is_active::boolean as is_active,
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
