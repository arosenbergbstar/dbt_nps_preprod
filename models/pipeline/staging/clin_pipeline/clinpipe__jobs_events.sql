with
    source as (select * from {{ source("clin_pipeline_snowpipe", "jobs_events") }}),
    renamed as (
        select
            {{ adapter.quote("EVENT") }} as event,
            {{ json_extract("ITEM_DATA", ["job_id"]) }} as job_id,
            {{ json_extract("ITEM_DATA", ["launch_directory"]) }} as launch_directory,
            {{ json_extract("ITEM_DATA", ["message"]) }} as event_message,
            {{ json_extract("ITEM_DATA", ["status"]) }} as event_status,
            {{ json_extract("ITEM_DATA", ["task_name"]) }} as task_name,
            {{ json_extract("ITEM_DATA", ["updated_at"]) }} as updated_at,
            {{ adapter.quote("MODIFIED_AT") }} as elt_modified_at,
            {{ adapter.quote("EMITTED_AT") }} as elt_emitted_at

        from source
    ),
    typed as (
        select
            event::text as event,
            job_id::text as job_id,
            launch_directory::text as launch_directory,
            event_message::text as event_message,
            event_status::text as event_status,
            task_name::text as task_name,
            updated_at::timestamp_tz as updated_at,
            elt_modified_at::timestamp_tz as elt_modified_at,
            elt_emitted_at::timestamp_tz as elt_emitted_at
        from renamed
    )
select *
from typed
order by updated_at desc
