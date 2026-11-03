{# Non-PII projection of lv__s_sample_pii, following the dbt_base lv__s_request pattern. #}
with
    src as (select * from {{ ref("lv__s_sample_pii") }}),
    final as ({{ filter_snowmask_columns("lv__s_sample_pii") }})
select *
from final
