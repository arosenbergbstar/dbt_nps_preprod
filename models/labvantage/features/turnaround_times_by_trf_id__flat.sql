{# 
    Commented sections implement new functionality and is not completely defined.
    Uncommented sections implement existing TAT logic.
#}
with
    int_timestamps_by_purified_plasma_id as (
        select * from {{ ref("int_timestamps_by_purified_plasma_id") }}
    ),
    sample_timestamps as (
        select
            request_id,
            min(received_at) as received_at,
            max(flowcell_processing_completed_at) as flowcell_processing_completed_at
        from int_timestamps_by_purified_plasma_id
        group by 1
    ),
    int_timestamps_by_trf_id as (select * from {{ ref("int_timestamps_by_trf_id") }}),
    {#
        Recreated from the dbt_prod dim_dates date spine (only the columns needed
        here). Business days = weekdays; holidays are not excluded, matching the
        original logic.
    #}
    date_spine as (
        {{
            dbt_utils.date_spine(
                start_date="to_date('01/01/1900', 'mm/dd/yyyy')",
                datepart="day",
                end_date="dateadd(year, 40, current_date)",
            )
        }}
    ),
    business_days as (
        select date_day, date_day as date_actual, dayname(date_day) as day_name
        from date_spine
        where dayname(date_day) not in ('Sat', 'Sun')
    ),
    ctat as (
        {# If Reports are generated #}
        select
            trf_id,
            request_id,
            datediff('day', received_at, initial_report_at) ctat_in_days
        from int_timestamps_by_trf_id
        left join sample_timestamps using (request_id)
        where initial_report_at is not null
    {# If Reports are not generated #}
    -- union
    -- select
    -- trf_id,
    -- request_id,
    -- datediff('day', received_at, flowcell_processing_completed_at) ctat_in_days
    -- from sample_timestamps
    -- inner join int_timestamps_by_trf_id using (request_id)
    {# 
            This filters for SAFE-D samples for testing, this will be replaced by 
            a list of study IDs if we move forward with this strategy.
        #}
    -- where trf_id like 'CNC%'
    ),
    btat as (
        {# If Reports are generated #}
        select request_id, count(distinct business_days.date_day) btat_in_days
        from int_timestamps_by_trf_id
        left join sample_timestamps using (request_id)
        left join
            business_days
            on business_days.date_actual >= sample_timestamps.received_at::date
            and business_days.date_actual
            <= int_timestamps_by_trf_id.initial_report_at::date
        where initial_report_at is not null
        group by 1
    {# If Reports are not generated #}
    -- union
    -- select request_id, count(distinct business_days.date_day) btat_in_days
    -- from sample_timestamps
    -- inner join int_timestamps_by_trf_id using (request_id)
    -- left join
    -- business_days
    -- on business_days.date_actual >= sample_timestamps.received_at::date
    -- and business_days.date_actual <=
    -- sample_timestamps.flowcell_processing_completed_at::date
    -- where trf_id like 'CNC%'
    -- group by 1
    ),
    main as (
        select trf_id, request_id, ctat_in_days, btat_in_days
        from ctat
        left join btat using (request_id)
    )

select *
from main
