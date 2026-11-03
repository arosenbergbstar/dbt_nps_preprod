{% set src = source("labvantage", "reporteventitem") %}
with
    source as (select * from {{ src }}),

    renamed as (
        select
            {{ adapter.quote("ITEMKEYID1") }} as item_key_id_1,
            {{ adapter.quote("ITEMKEYID2") }} as item_key_id_2,
            {{ adapter.quote("ITEMKEYID3") }} as item_key_id_3,
            {{ adapter.quote("REPORTEVENTITEMID") }} as report_event_item_id,
            {{ adapter.quote("REPORTEVENTID") }} as report_event_id,
            {{ adapter.quote("ITEMSDCID") }} as item_scd_id,
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
            report_event_id::text as report_event_id,
            -- seems to always be 0
            report_event_item_id::text as report_event_item_id,
            item_key_id_1::text as item_key_id_1,
            nullif(item_key_id_2, '(null)')::text as item_key_id_2,
            nullif(item_key_id_3, '(null)')::text as item_key_id_3,
            item_scd_id::text as item_scd_id,
            modified_by::text as modified_by,
            created_by::text as created_by,
            {{ cast_timestamp_tz("modified_at", "UTC") }},
            {{ cast_timestamp_tz("created_at", "UTC") }},
            elt_emitted_at::timestamp_tz as elt_emitted_at,
            elt_hash_id::text as elt_hash_id
        from renamed
    )

select *
from typed
