with
    src as (select * from {{ ref("lv__s_samplefamily_pii") }}),
    final as ({{ filter_snowmask_columns("lv__s_samplefamily_pii") }})
select *
from final
