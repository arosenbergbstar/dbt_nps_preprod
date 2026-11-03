-- {{ config(post_hook=["{{ apply_nodmed_row_access( this ) }}"]) }}

with
    stg_clia_pipeline__results as (select * from {{ ref("stg_clia_pipeline__results") }}),

    final as (
        select * exclude (hash_id)
        from stg_clia_pipeline__results
        qualify row_number() over (partition by job_id order by emitted_at desc) = 1
    )

select *
from final
