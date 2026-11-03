-- {{ config(post_hook=["{{ apply_nodmed_row_access( this ) }}"]) }}

with
    stg_clia_pipeline__jobs as (select * from {{ ref("stg_clia_pipeline__jobs") }}),

    final as (
        select * exclude (hash_id)
        from stg_clia_pipeline__jobs
    )

select *
from final
