{% set src = source("labvantage", "worksheet") %}
with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("MODBY") }} as modified_by,
            {{ adapter.quote("MODDT") }} as modified_at,
            {{ adapter.quote("NOTES") }} as notes,
            {{ adapter.quote("LESFLAG") }} as is_les,
            {{ adapter.quote("AUTHORDT") }} as authored_at,
            {{ adapter.quote("AUTHORID") }} as authored_by,
            {{ adapter.quote("COREFLAG") }} as is_core,
            {{ adapter.quote("CREATEBY") }} as created_by,
            {{ adapter.quote("CREATEDT") }} as created_at,
            {{ adapter.quote("BLOCKFLAG") }} as is_blocked,
            {{ adapter.quote("ACTIVEFLAG") }} as is_active,
            {{ adapter.quote("BLOCKSDCID") }} as blocksdc_id,
            {{ adapter.quote("TEMPLATEID") }} as template_id,
            {{ adapter.quote("WORKBOOKID") }} as workbook_id,
            {{ adapter.quote("WORKSHEETID") }} as worksheet_id,
            {{ adapter.quote("TEMPLATEFLAG") }} as is_template,
            {{ adapter.quote("VERSIONSTATUS") }} as version_status,
            {{ adapter.quote("WORKSHEETDESC") }} as worksheet_description,
            {{ adapter.quote("WORKSHEETNAME") }} as worksheet_name,
            {{ adapter.quote("WORKSHEETSTATUS") }} as worksheet_status,
            {{ adapter.quote("TEMPLATETYPEFLAG") }} as template_type,
            {{ adapter.quote("TEMPLATEVERSIONID") }} as template_version_number,
            {{ adapter.quote("VERSIONAPPROVEDDT") }} as version_approved_at,
            {{ adapter.quote("WORKBOOKVERSIONID") }} as workbook_version_number,
            {{ adapter.quote("VERSIONEFFECTIVEDT") }} as version_effective_at,
            {{ adapter.quote("WORKSHEETVERSIONID") }} as worksheet_version_number,
            {{ adapter.quote("TEMPLATEPRIVACYFLAG") }} as template_privacy_type,
            -- Indicates amend/correct
            {{ adapter.quote("U_REPORTTYPE") }} as report_type,
            {{ adapter.quote("U_REPORTTYPEVER") }} as report_type_version,
            {{ adapter.quote("U_REASON") }} as report_reason,  -- Not sure why this field exists. Seems to be redundant with report type and description
            -- Explains why amend/correct was needed
            {{ adapter.quote("U_DESCRIPTION") }} as report_description,
            {{ airbyte_get_emit_col(src) }} as elt_emitted_at,
            {{ airbyte_get_id_col(src) }} as elt_hash_id

        from source
    ),

    typed as (
        select
            workbook_id::text as workbook_id,
            worksheet_id::text as worksheet_id,
            template_id::text as template_id,
            blocksdc_id::text as blocksdc_id,
            worksheet_name::text as worksheet_name,
            worksheet_description::text as worksheet_description,
            worksheet_status::text as worksheet_status,
            report_type::text as report_type,
            report_type_version::int as report_type_version,
            report_description::text as report_description,
            {{ cast_timestamp_tz("version_approved_at", "UTC") }},
            {{ cast_timestamp_tz("version_effective_at", "UTC") }},
            notes::text as notes,
            version_status::text as version_status,
            is_active::boolean as is_active,
            is_blocked::boolean as is_blocked,
            is_core::boolean as is_core,
            is_les::boolean as is_les,
            is_template::boolean as is_template,
            template_privacy_type::text as template_privacy_type,
            template_type::text as template_type,
            template_version_number::int as template_version_number,
            workbook_version_number::int as workbook_version_number,
            worksheet_version_number::int as worksheet_version_number,
            authored_by::text as authored_by,
            modified_by::text as modified_by,
            created_by::text as created_by,
            {{ cast_timestamp_tz("authored_at", "UTC") }},
            {{ cast_timestamp_tz("modified_at", "UTC") }},
            {{ cast_timestamp_tz("created_at", "UTC") }},
            elt_emitted_at::timestamp_tz as elt_emitted_at,
            elt_hash_id::text as elt_hash_id
        from renamed
    )

select *
from typed
