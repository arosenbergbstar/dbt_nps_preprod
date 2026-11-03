{% set src = source("labvantage", "reportevent") %}
with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("REPORTID") }} as report_id,
            {{ adapter.quote("MODBY") }} as modified_by,
            {{ adapter.quote("MODDT") }} as modified_at,
            {{ adapter.quote("CREATEBY") }} as created_by,
            {{ adapter.quote("CREATEDT") }} as created_at,
            {{ adapter.quote("EVENTTYPE") }} as event_type,
            {{ adapter.quote("ACTIVEFLAG") }} as is_active,
            {{ adapter.quote("REVIEWEDBY") }} as reviewed_by,
            {{ adapter.quote("REVIEWEDDT") }} as reviewed_at,
            {{ adapter.quote("DISPLAYTYPE") }} as display_type,
            {{ adapter.quote("DISPOSITION") }} as disposition,
            {{ adapter.quote("TEMPLATEFLAG") }} as is_template,
            {{ adapter.quote("PARENTEVENTID") }} as parent_event_id,
            {{ adapter.quote("REPORTEVENTID") }} as report_event_id,
            {{ adapter.quote("REPORTEVENTDESC") }} as report_event_description,
            {{ adapter.quote("REPORTVERSIONID") }} as report_version,
            {{ adapter.quote("NOTES") }} as notes,
            {{ adapter.quote("REPORTCONTENT") }} as report_content,
            {{ airbyte_get_emit_col(src) }} as elt_emitted_at,
            {{ airbyte_get_id_col(src) }} as elt_hash_id
        from source
    ),
    typed as (
        select
            report_event_id::text as report_event_id,
            parent_event_id::text as parent_event_id,
            report_id::text as report_id,
            report_event_description::text as report_event_description,
            event_type::text as event_type,
            reviewed_by::text as reviewed_by,
            {{ cast_timestamp_tz("reviewed_at", "UTC") }},
            report_content::text as report_content,
            notes::text as notes,
            display_type::text as display_type,
            disposition::text as disposition,
            is_template::text as is_template,
            is_active::boolean as is_active,
            report_version::text as report_version,
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
