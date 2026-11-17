with
    trackitem as (
        select * from {{ ref("lv__trackitem") }} where link_sdc_id = 'LV_ReagentLot'
    ),
    reagentlot as (select * from {{ ref("lv__reagentlot") }}),
    arrayzonecontent as (select * from {{ ref("lv__arrayzonecontent") }}),
    arrayitemarrayzone as (select * from {{ ref("lv__arrayitemarrayzone") }}),
    main as (
        select
            arrayitemarrayzone.array_item_id,
            reagentlot.container_type_id,
            reagentlot.reagent_type_id,
            reagentlot.reagent_class,
            reagentlot.manufacturer_lot_id as manufacturer_lot
        from trackitem
        inner join reagentlot on trackitem.link_key_id_1 = reagentlot.reagent_lot_id
        left join
            arrayzonecontent
            on arrayzonecontent.content_key_id_1 = trackitem.track_item_id
        left join
            arrayitemarrayzone
            on arrayitemarrayzone.array_zone_id = arrayzonecontent.array_zone_id
        qualify
            row_number() over (
                partition by
                    arrayitemarrayzone.array_item_id,
                    reagentlot.reagent_type_id,
                    reagentlot.manufacturer_lot_id
                order by arrayzonecontent.array_zone_id asc
            )
            = 1
    )

select *
from main
