{% set li892_effective_date = "2026-07-13 00:00:00 -0700" %}

with
    reporteventitem as (
        select report_event_id, request_id from {{ ref("lv__reporteventitem") }}
    ),
    reportevent as (
        select
            report_event_id,
            report_id,
            event_type,
            disposition,
            report_content,
            created_at
        from {{ ref("lv__reportevent") }}
    ),

    report as (
        select
            reporteventitem.request_id,
            reportevent.report_id,
            reportevent.event_type,
            reportevent.disposition,
            reportevent.report_content,
            reportevent.report_event_id,
            reportevent.created_at as report_at,
            iff(
                reportevent.report_id = 'PatientReportQNS', true, false
            ) as is_fasttrack_qns_reportid,
            case
                when reportevent.report_id in ('Multicancer_AM', 'PatientReport_AmCr_D')
                then 'amended_corrected'
                when
                    reportevent.report_id in (
                        'PatientReport',
                        'PatientReportQNS',
                        'IVD_PancV2',
                        'LDT_PancV2',
                        'IVD_MCD',
                        'LDT_MCD'
                    )
                then 'initial'
                else 'unclassified'
            end as report_type
        from reporteventitem
        inner join reportevent using (report_event_id)
        where reportevent.report_content is not null
    ),
    {# 
        Prior to LI-892 the event_type and disposition fields were used inconsistently.
        The best method for getting the correct report for each TRF was to pull the most
        recent row with a non-null report content. 
        
        That method wound up creating issues with reports that go through bulk approval 
        because the most recent row is sometimes formatted as Jasper Config Bytes instead 
        of PDF and the DTT can't process them.

        The join to the worksheet model is simply to get the report subtype as either Amended 
        or Corrected since this information is not obtainable throught the request -> report event 
        path. Because worksheet joins report event on request and report type, if a request has 
        worksheets for both ammended and corrected, this will create duplicate rows for a report event, 
        one with Corrected subtype and one with Amended subtype. Yet the report content will only be of 
        one type.

        This could lead to mis-reporting the type a report really is as well as phantom inflation of the 
        actual number of reports. To date this has only happened once for request R-20260313-00007 / 
        report event 1006724-1. Since this seems to be a very rare event, we'll continue ot use the worksheet 
        to obtain subtype but will place tests in yml to detect and warn on duplicate report events in this model.
    #}
    report_preli892 as (
        select *
        from report
        where report_at < '{{ li892_effective_date }}'::timestamp_tz
    ),
    {#
        LI-892 introduces consistent use of event_type and disposition, so we can 
        use those fields to determine which row in the report table is the final
        version, formatted as a PDF, that is intended for release to the customer.
    #}
    report_postli892 as (
        select *
        from report
        {#
            Only return the "consumable" record based on the updates in LI-892.
        #}
        where
            event_type = 'Export'
            and disposition = 'Complete'
            and report_at >= '{{ li892_effective_date }}'::timestamp_tz
    ),
    report_consolidated as (
        select *
        from report_preli892 pre
        union all
        select *
        from report_postli892
    ),
    final as (
        select
            request_id,
            report_id,
            event_type,
            disposition,
            report_content,
            report_event_id,
            report_at,
            is_fasttrack_qns_reportid,
            report_type
        from report_consolidated
    )

select *
from final
