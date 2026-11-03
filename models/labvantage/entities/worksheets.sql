with
    {# Transformation recreated from dbt_prod stg_lv__s_requests #}
    request as (
        select request_id, trf_id, study_id
        from {{ ref("lv__s_request_pii") }}
        qualify row_number() over (partition by trf_id order by modified_at desc) = 1
    ),
    {# Transformation recreated from dbt_prod stg_samples #}
    sample_ as (
        select s_sampleid as sample_id, requestid as request_id
        from {{ ref("s_sample") }}
    ),
    {# Transformation recreated from dbt_prod stg_worksheet #}
    worksheet as (
        select
            worksheet_id,
            {# Source column is misspelled ('nummber'); corrected here. #}
            template_version_nummber as template_version_number,
            worksheet_version_number,
            template_id,
            report_type,
            created_at
        from {{ ref("lv__worksheet") }}
    ),
    {# Transformation recreated from dbt_prod stg_worksheetsdi #}
    worksheetsdi as (
        select worksheet_id, sdc_id, key_id_1 as sample_id
        from {{ ref("lv__worksheetsdi") }}
    ),

    worksheet_data as (
        select
            worksheet.worksheet_id,
            worksheet.worksheet_version_number,
            worksheet.template_id,
            worksheet.created_at,
            worksheet.report_type as source_report_type,
            case
                when worksheet.report_type = 'Amended'
                then 'amended'
                when worksheet.report_type = 'Corrected'
                then 'corrected'
                when  {# this may not be needed based on conversation with Lab Vantage team #}
                    worksheet.template_id in (
                        'Patient Report MULTI CANCER_W',
                        'Patient Report Panc_W',
                        'Patient Report Ovarian_W',
                        {# Misspelled source template; retained for back-compat. #}
                        'PaitientReport_W'
                    )
                then 'initial'
                else 'unclassified'
            end as report_subtype,
            request.request_id,
            request.trf_id,
            request.study_id
        from worksheet
        inner join worksheetsdi using (worksheet_id)
        inner join sample_ using (sample_id)
        inner join request using (request_id)
        where sdc_id = 'Sample'
        {# 
            This really shouldn't be needed, but Gezi did a bunch of testing in March 2026 and created some instances 
            where a worksheet ID/version combo is duplicated, which is breaking the tests.
        #}
        qualify
            row_number() over (
                partition by request_id, worksheet_id, worksheet_version_number
                order by created_at asc
            )
            = 1
    ),

    final as (
        select
            worksheet_id,
            worksheet_version_number,
            template_id,
            created_at,
            source_report_type,
            report_subtype,
            case
                when report_subtype in ('amended', 'corrected')
                then 'amended_corrected'
                when report_subtype = 'initial'
                then 'initial'
                else 'unclassified'
            end as report_type,
            request_id,
            trf_id,
            study_id
        from worksheet_data
    )

select *
from final
