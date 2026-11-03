{% set columns = dbt_utils.get_filtered_columns_in_relation(
    ref("stg_clia_pipeline__triage"), ["HASH_ID"]
) %}

with
    stg_clia_pipeline__triage as (select * from {{ ref("stg_clia_pipeline__triage") }}),

    final as (
        select
            {% for col in columns %}
            "{{ col }}"{% if not loop.last %}, {% endif %}
            {% endfor %}
        from stg_clia_pipeline__triage
        qualify row_number() over (partition by hash_id order by emitted_at asc) = 1
    )

select *
from final
