{{ config(post_hook=["{{ apply_nodmed_row_access( this ) }}"]) }}

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
    final as (
        select * exclude _dbt_source_relation
        from unioned
        qualify row_number() over (partition by hash_id order by emitted_at asc) = 1
    )

select *
from final
order by emitted_at asc, event asc
