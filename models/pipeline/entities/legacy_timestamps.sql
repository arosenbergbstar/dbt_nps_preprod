with
    {#
        Filter and dedupe logic recreated from dbt_prod stg_clia_pipeline_jobs.

        The status filter drops the init (null) record; there are usually 3 records
        per run - null (init), started, completed.
        The dedupe keeps the earliest record per job/status. Most instances where
        duplicates come up involve an extra completed record but no started record
        (eg ps002785), so later re-runs are ignored. They don't affect CLIA samples.
    #}
    clia_pipeline_jobs as (
        select job_id, pipeline_status, emitted_at
        from {{ ref("clia_pipeline__jobs") }}
        where event != 'REMOVE' and pipeline_status is not null
        qualify
            row_number() over (
                partition by job_id, pipeline_status order by emitted_at asc
            )
            = 1
    ),
    timestamps as (
        select
            job_id,
            max(iff(pipeline_status = 'started', emitted_at, null)) started_at,
            max(iff(pipeline_status in ('complete','ERROR'), emitted_at, null)) completed_at,
            max(
                iff(pipeline_status = 'ERROR', true, false)
            ) as has_pipeline_completed_with_error
        from clia_pipeline_jobs
        group by job_id
    )

select *
from timestamps
