{{ config(post_hook=["{{ apply_nodmed_row_access( this ) }}"]) }}

{% set columns = dbt_utils.get_filtered_columns_in_relation(
    ref("stg_clia_pipeline__jobs"), ["HASH_ID"]
) %}

with
    stg_clia_pipeline__jobs as (select * from {{ ref("stg_clia_pipeline__jobs") }}),

    final as (
        select
            {% for col in columns %}
            "{{ col }}"{% if not loop.last %}, {% endif %}
            {% endfor %}
        from stg_clia_pipeline__jobs
    )

select *
from final
