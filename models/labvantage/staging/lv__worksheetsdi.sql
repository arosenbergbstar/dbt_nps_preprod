{% set src = source("labvantage", "worksheetsdi") %}
with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("MODBY") }} as modified_by,
            {{ adapter.quote("MODDT") }} as modified_at,
            {{ adapter.quote("CREATEBY") }} as created_by,
            {{ adapter.quote("CREATEDT") }} as created_at,
            {{ adapter.quote("WORKSHEETID") }} as worksheet_id,
            {{ adapter.quote("WORKSHEETVERSIONID") }} as worksheet_version_number,
            {{ adapter.quote("SDCID") }} as sdc_id,
            -- contains different values based on SDCID.
            {{ adapter.quote("KEYID1") }} as key_id_1,
            {{ adapter.quote("KEYID2") }} as key_id_2,  -- rarely used
            {{ adapter.quote("KEYID3") }} as key_id_3,  -- unused
            {{ airbyte_get_emit_col(src) }} as elt_emitted_at,
            {{ airbyte_get_id_col(src) }} as elt_hash_id

        from source
    ),

    typed as (
        select
            worksheet_id::text as worksheet_id,
            sdc_id::text as sdc_id,
            key_id_1::text as key_id_1,
            nullif(key_id_2, '(null)')::text as key_id_2,
            nullif(key_id_3, '(null)')::text as key_id_3,
            worksheet_version_number::int as worksheet_version_number,
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
