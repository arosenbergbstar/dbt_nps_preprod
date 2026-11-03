with
    all_pp_samples_cancelled as (
        select
            request_id,
            count(distinct purified_plasma_id) =
            count(distinct iff(cancelled_at is not null, purified_plasma_id, null)) as is_cancelled_all_pp_aliquots
        from {{ ref("samples") }}
        where sample_type_id = 'Purified Plasma'
        group by 1
    ),
    all_wb_samples_cancelled as (
        select
            request_id,
            count(distinct sample_id) = 
            count(distinct iff(cancelled_at is not null, sample_id, null)) as is_cancelled_all_wb_aliquots
        from {{ ref("samples") }}
        where sample_type_id = 'Whole Blood' 
        group by 1
    ),
    requests as (
        select
            trf_id,
            request_id,
            date_trunc('second', accessioned_at) as accessioned_at_sec,
            date_trunc('second', rejected_at) as rejected_at_sec,
            date_trunc('second', cancelled_at) as cancelled_at_sec
        from {{ ref("requests") }}
    ),
    request_timestamps as (
        select
            trf_id,
            request_id,
            min(accessioned_at_sec) as accessioned_at,
            min(rejected_at_sec) as rejected_at,
            min(cancelled_at_sec) as cancelled_at
        from requests
        group by 1, 2
    ),
    reports as (
        select *, date_trunc('second', report_at) as report_at_sec
        from {{ ref("int_reports_with_type") }}
    ),
    report_timestamps as (
        select
            request_id,
            min(
                iff(report_subtype = 'initial', report_at_sec, null)
            ) as initial_report_at,
            min(
                iff(report_subtype = 'corrected', report_at_sec, null)
            ) as corrected_report_at,
            min(
                iff(report_subtype = 'amended', report_at_sec, null)
            ) as amended_report_at
        from reports
        group by 1
    ),
    main as (
        select
            trf_id,
            request_id,
            -- received_at,
            accessioned_at,
            rejected_at,
            cancelled_at,
            initial_report_at,
            corrected_report_at,
            amended_report_at,
            is_cancelled_all_pp_aliquots,
            is_cancelled_all_wb_aliquots
        from request_timestamps
        left join all_pp_samples_cancelled using (request_id)
        left join all_wb_samples_cancelled using (request_id)
        left join report_timestamps using (request_id)
    )

select *
from main
