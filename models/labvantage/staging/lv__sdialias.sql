{% set src = source("labvantage", "sdialias") %}

with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("SDCID") }} as sdc_id,
            {{ adapter.quote("KEYID1") }} as key_id_1,
            {{ adapter.quote("KEYID2") }} as key_id_2,
            {{ adapter.quote("KEYID3") }} as key_id_3,
            {{ adapter.quote("ALIASID") }} as alias_id,
            {{ adapter.quote("ALIASTYPE") }} as alias_type,
            {{ adapter.quote("AUDITSEQUENCE") }} as audit_sequence,
            {{ adapter.quote("CREATEDT") }} as created_at,
            {{ adapter.quote("CREATEBY") }} as created_by,
            {{ adapter.quote("MODBY") }} as modified_by,
            {{ adapter.quote("MODDT") }} as modified_at,
            {{ airbyte_get_emit_col(src) }} as elt_emitted_at,
            {{ airbyte_get_id_col(src) }} as elt_hash_id

        from source
    ),
    typed as (
        select
            sdc_id::text as sdc_id,
            nullif(key_id_1::text, '(null)') as key_id_1,
            nullif(key_id_2::text, '(null)') as key_id_2,
            nullif(key_id_3::text, '(null)') as key_id_3,
            alias_id::text as alias_id,
            alias_type::text as alias_type,
            audit_sequence::integer as audit_sequence,
            modified_by::text as modified_by,
            {{ cast_timestamp_tz("modified_at", "UTC") }},
            created_by::text as created_by,
            {{ cast_timestamp_tz("created_at", "UTC") }},
            elt_emitted_at::timestamp as elt_emitted_at,
            elt_hash_id::text as elt_hash_id

        from renamed
    )

select *
from typed
