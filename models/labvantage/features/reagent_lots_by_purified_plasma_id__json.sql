with
    reagent_lot_values as (
        select distinct
            samples.purified_plasma_id,
            reagent_lots.reagent_type_id,
            reagent_lots.manufacturer_lot
        from {{ ref("array_items") }}
        inner join {{ ref("samples") }} using (sample_id)
        inner join {{ ref("reagent_lots") }} using (array_item_id)
        where reagent_lots.manufacturer_lot is not null
    ),
    reagent_lots_deduped as (
        select
            purified_plasma_id,
            reagent_type_id,
            count(distinct manufacturer_lot) as lot_count,
            array_agg(distinct manufacturer_lot) within group (
                order by manufacturer_lot asc
            ) as manufacturer_lots,
            max(manufacturer_lot) as single_manufacturer_lot
        from reagent_lot_values
        group by 1, 2
    ),
    main as (
        select
            purified_plasma_id,
            object_agg(
                reagent_type_id,
                iff(
                    lot_count = 1,
                    single_manufacturer_lot::variant,
                    manufacturer_lots::variant
                )
            ) as reagent_lots
        from reagent_lots_deduped
        group by 1
    )

select *
from main
