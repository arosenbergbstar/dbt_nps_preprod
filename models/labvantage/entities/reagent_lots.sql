with
    trackitem as (
        select *
        from {{ ref("trackitem") }}
        where trackitem.linksdcid = 'LV_ReagentLot'
    ),
    reagentlot as (select * from {{ ref("reagentlot") }}),
    arrayzonecontent as (select * from {{ ref("arrayzonecontent") }}),
    arrayitemarrayzone as (
        select * from {{ ref("arrayitemarrayzone") }}
    ),
    main as (
        select
            arrayitemarrayzone.arrayitemid as array_item_id,
            reagentlot.containertypeid as container_type_id,
            reagentlot.reagenttypeid as reagent_type_id,
            reagentlot.reagentclass as reagent_class,
            reagentlot.manufacturerlot as manufacturer_lot
        from trackitem
        inner join reagentlot on trackitem.linkkeyid1 = reagentlot.reagentlotid
        left join
            arrayzonecontent on arrayzonecontent.contentkeyid1 = trackitem.trackitemid
        left join
            arrayitemarrayzone
            on arrayitemarrayzone.arrayzoneid = arrayzonecontent.arrayzoneid
        qualify
            row_number() over (
                partition by array_item_id, reagent_type_id, manufacturer_lot
                order by arrayzonecontent.arrayzoneid asc
            )
            = 1
    )

select *
from main
