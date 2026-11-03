with
    operations as (
        select distinct
            samples.purified_plasma_id, array_items.array_desc, array_items.array_id
        from {{ ref("array_items") }}
        inner join {{ ref("samples") }} using (sample_id)
        {# Exclude placeholder arrays #}
        where array_id not like 'Pla-%'
    ),
    operations_deduped as (
        select
            purified_plasma_id,
            array_desc,
            count(distinct array_id) as operation_count,
            array_agg(distinct array_id) within group (
                order by array_id asc
            ) as operation_array_id_list,
            min(array_id) as first_operation_array_id
        from operations
        group by 1, 2
    ),
    main as (
        select
            purified_plasma_id,
            object_agg(
                array_desc,
                iff(
                    operation_count = 1,
                    first_operation_array_id::variant,
                    operation_array_id_list::variant
                )
            ) as arrays
        from operations_deduped
        group by purified_plasma_id
    )

select *
from main
