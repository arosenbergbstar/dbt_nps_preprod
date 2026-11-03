with
    stg_clia_pipeline__triage as (select * from {{ ref("stg_clia_pipeline__triage") }}),

    final as (
        select * exclude (hash_id)
        from stg_clia_pipeline__triage
        qualify row_number() over (partition by hash_id order by emitted_at asc) = 1
    )

select *
from final
