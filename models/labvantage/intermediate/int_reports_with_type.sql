{# 
    Effective date for LI-892/DO-623, which impacts report status columns.
    Correct report result row is determined differently pre/post this date.
#}
{% set li892_effective_date = "2026-07-13 00:00:00 -0700" %}

with
    /**
    This is a consolidated Labvantage Report Model that's intended to replace
    fact_report_approvals, fact_report_results and fact_report_special_types and 
    power reporting models like Vanguard DTT and Customer Enrollment. 


    Report classification (the controlled-vocabulary matching on template_id and
    report_id) lives in two upstream intermediate models, each tested on its own
    output. Values those models can't classify resolve to 'unclassified' and are
    excluded below, so an unrecognized source value is dropped deterministically
    rather than absorbed into a catch-all that can produce spurious matches.
    **/
    report_worksheet as (
        select distinct request_id, report_type, report_subtype
        from {{ ref("worksheets") }}
        where report_type != 'unclassified'
    ),

    report_without_subtype as (
        select
            request_id,
            report_type,
            event_type,
            disposition,
            report_content,
            report_event_id,
            report_at,
            is_fasttrack_qns_reportid
        from {{ ref("reports") }}
        where report_type != 'unclassified'
    ),

    {# Undesireable way to get get report subtype into the report but all we have at this point#}
    report as (
        select distinct
            report_without_subtype.request_id,
            report_without_subtype.report_content,
            report_without_subtype.report_at,
            report_without_subtype.is_fasttrack_qns_reportid,
            report_without_subtype.report_event_id,
            report_without_subtype.event_type,
            report_without_subtype.disposition,
            report_worksheet.report_subtype
        from report_without_subtype
        inner join report_worksheet using (request_id, report_type)
    ),

    final as (
        select
            request_id,
            report_content,
            report_at,
            report_subtype,
            is_fasttrack_qns_reportid as is_qns_reportid,  {# renamed for downstream compatibility.#}
            report_event_id
        from report
        {#
            Moved the qualify down here to address two additional issues:
            1. It properly dedupes a small number of Vanguard samples that had reports 
               generated both before and after the cutoff date.
            2. It properly dedupes samples where multiple report event ids with export/completed 
               status exist for a single request id. @dwatson has confirmed this is a potential issue. 
               It should be resolved in the future by linking reports with worksheets and jobs instead 
               of request.
        #}
        qualify
            row_number() over (
                partition by request_id, report_subtype order by report_event_id desc
            )
            = 1
    )

select *
from final
