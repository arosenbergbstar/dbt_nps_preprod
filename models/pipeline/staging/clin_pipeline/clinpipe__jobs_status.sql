with
    source as (select * from {{ source("clin_pipeline_snowpipe", "jobs_status") }}),
    renamed as (
        select
            {{ adapter.quote("EVENT") }} as event,
            {{ json_extract("VALUE", ["job_id"]) }} as job_id,
            {{ json_extract("VALUE", ["status"]) }} as job_status,
            {{ json_extract("VALUE", ["pipeline_name"]) }} as pipeline_name,
            {{ json_extract("VALUE", ["pipeline_version"]) }} as pipeline_version,
            {{ json_extract("VALUE", ["updated_at"]) }} as updated_at,
            {{ adapter.quote("MODIFIED_AT") }} as modified_at
        from source
    ),
    typed as (
        select
            event::text as event,
            job_id::text as job_id,
            job_status::text as job_status,
            pipeline_name::text as pipeline_name,
            pipeline_version::text as pipeline_version,
            updated_at::timestamp_tz as updated_at,
            modified_at::timestamp_tz as elt_modified_at
        from renamed
    )
select *
from typed
