with
    extractions as (
        select request_id, purified_plasma_id, min(create_at) as extraction_at
        from {{ ref("samples") }}
        where sample_type_id = 'cfDNA'
        group by 1, 2
    ),
    extraction_order as (
        select
            request_id,
            purified_plasma_id,
            row_number() over (
                partition by request_id order by extraction_at asc
            ) extraction_order
        from extractions
    )

select *
from extraction_order
