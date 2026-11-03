{{ config(post_hook=["{{ apply_nodmed_row_access( this ) }}"]) }}

{% set columns = dbt_utils.get_filtered_columns_in_relation(
    ref("stg_clia_pipeline__results"), ["HASH_ID"]
) %}

with
    stg_clia_pipeline__results as (select * from {{ ref("stg_clia_pipeline__results") }}),

    final as (
        select
            {% for col in columns %}
                "{{ col }}"{% if not loop.last %}, {% endif %}
            {% endfor %}
        from stg_clia_pipeline__results
        qualify row_number() over (partition by job_id order by emitted_at desc) = 1
    )

select *
from final
