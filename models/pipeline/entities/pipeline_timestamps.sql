with
    clinpipe__jobs_status as (
        {{
            dbt_utils.deduplicate(
                relation=source("clin_pipeline", "clinpipe__jobs_status"),
                partition_by="job_id",
                order_by="updated_at desc",
            )
        }}
    ), 
    stg_clinpipe__jobs_events as (
        {{
            dbt_utils.deduplicate(
                relation=source("clin_pipeline", "clinpipe__jobs_events"),
                partition_by="job_id, event_status",
                order_by="updated_at desc",
            )
        }}
    ),   
    joined as (
        select job_id, event_status, {{ cast_timestamp_tz("updated_at", "UTC") }} 
        from stg_clinpipe__jobs_events
        inner join clinpipe__jobs_status using (job_id)
        where pipeline_name not in ('pancreatic','ovarian')
        
    ),  
    main as (
        select
            job_id,
            max(iff(event_status = 'started', updated_at, null)) as pipeline_started_at,
            max(
                iff(event_status like 'completed%', updated_at, null)
            ) as pipeline_completed_at,
            max(
                iff(event_status = 'completed_with_error', true, false)
            ) as has_pipeline_completed_with_error
        from joined
        group by 1
    )

select *
from main
