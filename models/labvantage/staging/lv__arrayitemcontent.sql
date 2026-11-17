{% set src = source("labvantage", "arrayitemcontent") %}

with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("CONTENTKEYID1") }} as content_key_id_1,
            {{ adapter.quote("CONTENTKEYID2") }} as content_key_id_2,
            {{ adapter.quote("CONTENTKEYID3") }} as content_key_id_3,
            {{ adapter.quote("CREATEDT") }} as created_at,
            {{ adapter.quote("PARENTARRAYITEMID") }} as parent_array_item_id,
            {{ adapter.quote("DILUENTVOLUMEUNITS") }} as diluent_volume_units,
            {{ adapter.quote("CREATEBY") }} as created_by,
            {{ adapter.quote("CONTENTSDCID") }} as content_sdc_id,
            {{ adapter.quote("CONTENTWORKITEMID") }} as content_work_item_id,
            {{ adapter.quote("CONTENTLABEL") }} as content_label,
            {{ adapter.quote("VOLUMEUNITS") }} as volume_units,
            {{ adapter.quote("CONTENTITEM") }} as content_item,
            {{ adapter.quote("USERSEQUENCE") }} as user_sequence,
            {{ adapter.quote("MODDT") }} as modified_at,
            {{ adapter.quote("TRACELOGID") }} as trace_log_id,
            {{ adapter.quote("DILUENTVOLUME") }} as diluent_volume,
            {{ adapter.quote("AUDITSEQUENCE") }} as audit_sequence,
            {{ adapter.quote("DILUTIONFACTOR") }} as dilution_factor,
            {{ adapter.quote("MODBY") }} as modified_by,
            {{ adapter.quote("CONCENTRATION") }} as concentration,
            {{ adapter.quote("CONTENTTYPE") }} as content_type,
            {{ adapter.quote("VOLUME") }} as volume,
            {{ adapter.quote("CONTENTWORKITEMINSTANCE") }}
            as content_work_item_instance,
            {{ adapter.quote("MODTOOL") }} as modified_tool,
            {{ adapter.quote("PARENTSTORAGEUNITID") }} as parent_storage_unit_id,
            {{ adapter.quote("SOURCEARRAYZONEID") }} as source_array_zone_id,
            {{ adapter.quote("ARRAYITEMCONTENTID") }} as array_item_content_id,
            {{ adapter.quote("CONCENTRATIONUNITS") }} as concentration_units,
            {{ adapter.quote("REPEATNUM") }} as repeat_num,
            {{ adapter.quote("CREATETOOL") }} as created_tool,
            {{ adapter.quote("ARRAYITEMID") }} as array_item_id,
            {{ airbyte_get_emit_col(src) }} as elt_emitted_at,
            {{ airbyte_get_id_col(src) }} as elt_hash_id
        from source
    ),
    typed as (
        select
            content_key_id_1::text as content_key_id_1,
            content_key_id_2::text as content_key_id_2,
            content_key_id_3::text as content_key_id_3,
            {{ cast_timestamp_tz("created_at", "UTC") }},
            parent_array_item_id::text as parent_array_item_id,
            diluent_volume_units::text as diluent_volume_units,
            created_by::text as created_by,
            content_sdc_id::text as content_sdc_id,
            content_work_item_id::text as content_work_item_id,
            content_label::text as content_label,
            volume_units::text as volume_units,
            content_item::text as content_item,
            user_sequence::integer as user_sequence,
            {{ cast_timestamp_tz("modified_at", "UTC") }},
            trace_log_id::text as trace_log_id,
            diluent_volume::float as diluent_volume,
            audit_sequence::integer as audit_sequence,
            dilution_factor::float as dilution_factor,
            modified_by::text as modified_by,
            concentration::float as concentration,
            content_type::text as content_type,
            volume::float as volume,
            content_work_item_instance::integer as content_work_item_instance,
            modified_tool::text as modified_tool,
            parent_storage_unit_id::text as parent_storage_unit_id,
            source_array_zone_id::text as source_array_zone_id,
            array_item_content_id::text as array_item_content_id,
            concentration_units::text as concentration_units,
            repeat_num::integer as repeat_num,
            created_tool::text as created_tool,
            array_item_id::text as array_item_id,
            elt_emitted_at::timestamp_tz as elt_emitted_at,
            elt_hash_id::text as elt_hash_id
        from renamed
    )

select *
from typed
