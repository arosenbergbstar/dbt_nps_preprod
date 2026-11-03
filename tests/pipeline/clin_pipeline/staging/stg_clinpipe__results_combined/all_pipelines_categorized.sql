{#
    Test that all pipelines are explicitly categorized.

    This test fails if any pipeline exists in the source data that is NOT
    explicitly listed in either clinpipe_v1_pipelines or clinpipe_v2_pipelines.

    Purpose: Prevent silent inclusion of new pipelines with potentially
    different JSON schemas. When a new pipeline is promoted, this test
    will fail and force a conscious decision about which category it belongs to.

    To fix a failure:
    1. Identify the new pipeline name in the test output
    2. Determine if it uses v1 schema (flat hmc_qc/wgs_qc) or v2 schema (outputs.qc_metrics)
    3. Add the pipeline name to the appropriate list in dbt_project.yml

    If a new pipeline introduces a v3 schema:
    - Create stg_clinpipe__results_json_v3.sql following the v1/v2 pattern
    - Add clinpipe_v3_pipelines to dbt_project.yml
    - Add the new model to dbt_utils.union_relations in stg_clinpipe__results_combined.sql
    - Update this test to include the v3 pipeline list
#}

select distinct pipeline_name
from {{ ref("stg_clinpipe__versioned_results") }}
where
    pipeline_name is not null
    and pipeline_name not in ('{{ var('clinpipe_v1_pipelines') | join("', '") }}')
    and pipeline_name not in ('{{ var('clinpipe_v2_pipelines') | join("', '") }}')
