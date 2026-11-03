with
    unioned as (
        {{
            dbt_utils.union_relations(
                relations=[
                    ref("stg_clinpipe__results_v1"),
                    ref("stg_clinpipe__results_v2"),
                    ref("stg_clinpipe__results_v3"),
                ]
            )
        }}

    ),

    deduped as (
        select * exclude _dbt_source_relation
        from unioned
        qualify row_number() over (partition by hash_id order by emitted_at asc) = 1
    ),

    final as (
        select * exclude (hash_id)
        from deduped
        qualify row_number() over (partition by job_id order by emitted_at desc) = 1
    )

select *
from final
