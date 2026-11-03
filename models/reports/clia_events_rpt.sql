with
    requests as (select request_id, study_id, trf_id from {{ ref("requests") }}),
    assigned_test as (select * from {{ ref("assigned_tests_by_trf_id__tall") }}),
    jobs as (select job_id, trf_id, purified_plasma_id from {{ ref("jobs") }}),
    study_metadata as (
        select study_id, study_type, patient_report_type
        from {{ ref("study_metadata") }}
    ),
    labvantage_sample_events as (
        select
            purified_plasma_id as event_id,
            event_name,
            event_at,
            study_id,
            study_type,
            patient_report_type,
            pipeline_name,
            is_multitest_request
        from {{ ref("timestamps_by_purified_plasma_id__tall") }}
        inner join requests using (request_id)
        inner join assigned_test using (request_id)
        left join study_metadata using (study_id)
    ),
    labvantage_request_events as (
        select
            trf_id as event_id,
            event_name,
            event_at,
            study_id,
            study_type,
            patient_report_type,
            pipeline_name,
            is_multitest_request
        from {{ ref("timestamps_by_trf_id__tall") }}
        inner join requests using (request_id)
        inner join assigned_test using (request_id)
        left join study_metadata using (study_id)
    ),
    pipeline_events as (
        select
            purified_plasma_id,
            operation_name as event_name,
            operation_at as event_at,
            study_id,
            study_type,
            patient_report_type,
            pipeline_name,
            is_multitest_request
        from {{ ref("timestamps_by_jobs__tall") }}
        inner join jobs using (job_id)
        inner join requests using (trf_id)
        inner join assigned_test using (request_id)
        left join study_metadata using (study_id)

    ),
    main as (
        select *
        from labvantage_sample_events
        union
        select *
        from labvantage_request_events
        union
        select *
        from pipeline_events
    )

select *
from main
