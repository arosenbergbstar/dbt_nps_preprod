with
    requests as (
        select distinct request_id, trf_id, b.value as purified_plasma_test_id
        from {{ ref("requests") }}, lateral split_to_table(work_item_id, ';') b
    ),
    request_workflows as (
        select distinct
            requests.request_id,
            requests.trf_id,
            purified_plasma_test_id,
            {{ map_workflow_type("purified_plasma_test_id") }} as pipeline_name
        from requests
    ),
    multitest as (
        select
            request_id,
            iff(
                count(distinct purified_plasma_test_id) > 1, true, false
            ) is_multitest_request
        from request_workflows
        group by 1
    ),
    final as (
        select
            request_id,
            trf_id,
            purified_plasma_test_id,
            pipeline_name,
            is_multitest_request
        from request_workflows
        inner join multitest using (request_id)
    )

select *
from final
