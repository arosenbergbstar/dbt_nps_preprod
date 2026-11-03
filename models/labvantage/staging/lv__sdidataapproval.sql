{% set src = source("labvantage", "sdidataapproval") %}
with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("KEYID1") }} as key_id_1,
            {{ adapter.quote("KEYID2") }} as key_id_2,
            {{ adapter.quote("KEYID3") }} as key_id_3,
            {{ adapter.quote("SDCID") }} as sdc_id,
            {{ adapter.quote("ROLEID") }} as role_id,
            {{ adapter.quote("VARIANTID") }} as variant_id,
            {{ adapter.quote("PARAMLISTID") }} as param_list_id,
            {{ adapter.quote("MODBY") }} as modified_by,
            {{ adapter.quote("MODDT") }} as modified_at,
            {{ adapter.quote("CREATEBY") }} as created_by,
            {{ adapter.quote("CREATEDT") }} as created_at,
            {{ adapter.quote("DATASET") }} as dataset,
            {{ adapter.quote("APPROVALFLAG") }} as approval_flag,
            {{ adapter.quote("APPROVALSTEP") }} as approval_step,
            {{ adapter.quote("FORCEPEERFLAG") }} as force_peer_flag,
            {{ adapter.quote("MANDATORYFLAG") }} as is_mandatory,
            {{ adapter.quote("PARAMLISTVERSIONID") }} as param_list_version,
            {{ adapter.quote("NOTES") }} as notes,
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
            approval_flag::text as approval_flag,
            approval_step::text as approval_step,
            force_peer_flag::text as force_peer_flag,
            is_mandatory::boolean as is_mandatory,
            notes::text as notes,
            sdc_id::text as sdc_id,
            role_id::text as role_id,
            dataset::text as dataset,
            variant_id::text as variant_id,
            param_list_id::text as param_list_id,
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
