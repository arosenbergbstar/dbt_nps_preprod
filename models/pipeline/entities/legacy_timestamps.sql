with
    timestamps as (
        select
            job_id,
            max(iff(pipeline_status = 'started', emitted_at, null)) started_at,
            max(iff(pipeline_status in ('complete','ERROR'), emitted_at, null)) completed_at,
            max(
                iff(pipeline_status = 'ERROR', true, false)
            ) as has_pipeline_completed_with_error
        {# 
            should be base, but it's a view and takes forever to run.
            need to change materialization to table
        #}
        from {{ ref("stg_clia_pipeline_jobs") }}
        group by job_id
    )

select *
from timestamps
