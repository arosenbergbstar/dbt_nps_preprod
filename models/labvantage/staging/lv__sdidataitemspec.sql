{% set src = source("labvantage", "sdidataitemspec") %}
with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("KEYID1") }} as key_id_1,
            {{ adapter.quote("KEYID2") }} as key_id_2,
            {{ adapter.quote("KEYID3") }} as key_id_3,
            {{ adapter.quote("SDCID") }} as sdc_id,
            {{ adapter.quote("SPECID") }} as spec_id,
            {{ adapter.quote("CONDITION") }} as condition,
            {{ adapter.quote("PARAMID") }} as param_id,
            {{ adapter.quote("PARAMTYPE") }} as param_type,
            {{ adapter.quote("VARIANTID") }} as variant_id,
            {{ adapter.quote("PARAMLISTID") }} as param_list_id,
            {{ adapter.quote("LIMITTYPEID") }} as limit_type_id,

            {{ adapter.quote("MODBY") }} as modified_by,
            {{ adapter.quote("MODDT") }} as modified_at,
            {{ adapter.quote("CREATEBY") }} as created_by,
            {{ adapter.quote("CREATEDT") }} as created_at,
            {{ adapter.quote("CHECKEDVALUE") }} as checked_value,
            {{ adapter.quote("DISPLAYVALUE") }} as display_value,
            {{ adapter.quote("SPECVERSIONID") }} as spec_version,
            {{ adapter.quote("PARAMLISTVERSIONID") }} as param_list_version,
            {{ airbyte_get_emit_col(src) }} as elt_emitted_at,
            {{ airbyte_get_id_col(src) }} as elt_hash_id

        from source
    ),
    typed as (
        select
            key_id_1::text as key_id_1,
            {# for some reason labvantage puts in string (null) for these key_id columns #}
            nullif(key_id_2, '(null)')::text as key_id_2,
            nullif(key_id_3, '(null)')::text as key_id_3,
            checked_value::text as checked_value,
            display_value::text as display_value,
            sdc_id::text as sdc_id,
            spec_id::text as spec_id,
            condition::text as condition,
            param_id::text as param_id,
            param_type::text as param_type,
            variant_id::text as variant_id,
            param_list_id::text as param_list_id,
            limit_type_id::text as limit_type_id,
            spec_version::text as spec_version,
            param_list_version::text as param_list_version,
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
