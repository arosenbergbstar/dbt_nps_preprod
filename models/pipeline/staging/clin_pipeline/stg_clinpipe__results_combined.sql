{#
    Unions v1 and v2 pipeline results into a single standardized table.

    v1 and v2 pipelines output results in different JSON formats. The upstream
    stg_clinpipe__results_json_v1 and stg_clinpipe__results_json_v2 models
    normalize these formats into a common column structure, enabling a simple
    union here.
#}

with
    final as (
        {{
            dbt_utils.union_relations(
                relations=[
                    ref("stg_clinpipe__results_json_v1"),
                    ref("stg_clinpipe__results_json_v2"),
                ]
            )
        }}
    )

select * exclude _dbt_source_relation
from final
order by emitted_at asc, job_id asc
