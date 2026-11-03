with
    timestamps as (select * from {{ ref("timestamps") }} where job_id like 'J-%'),
    main as (
        select
            job_id,
            'pipeline_started' as operation_name,
            'Pipeline' as operation_name_sparse,
            started_at as operation_at
        from timestamps
        where started_at is not null
        union
        select
            job_id,
            'pipeline_completed' as operation_name,
            'Pipeline' as operation_name_sparse,
            completed_at as operation_at
        from timestamps
        where completed_at is not null
    )

select *
from main
