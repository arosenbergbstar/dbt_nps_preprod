with
    {# Filters recreated from dbt_prod stg_arrays #}
    arrays as (
        select array_id, array_desc, array_layout_id
        from {{ ref("lv__array") }}
        where
            array_id not like 'TEST%'
            and array_id not like 'SDBB%'
            and array_id not ilike '%TEST%'
    ),
    arrayitems as (
        select
            array_item_id,
            array_id,
            item_label,
            created_by,
            modified_by,
            created_at,
            modified_at
        from {{ ref("lv__arrayitem") }}
    ),
    arrayitemcontents as (
        select
            contentkeyid1 as sample_id,
            arrayitemid as array_item_id,
            contenttype as content_type,
            contentitem as content_item
        from {{ ref("arrayitemcontent") }}
        where contenttype = 'Sample'
        qualify
            row_number() over (partition by arrayitemid order by contentkeyid1 asc) = 1
    ),
    flowcell_chemistry as (select * from {{ ref("int_flow_cell_chemistry") }}),
    operations as (
        select
            array_id,
            flowcell_process_type,
            {{
                map_array_type(
                    "array_id",
                    "array_desc",
                    "array_layout_id",
                    "flowcell_process_type",
                )
            }} as operation_name
        from arrays
        left join flowcell_chemistry on flowcell_chemistry.flowcell_id = arrays.array_id
    ),
    joined as (
        select
            arrays.array_id,
            arrayitems.array_item_id,
            arrayitemcontents.sample_id,
            iff(
                arrays.array_desc
                in ('Flow Cell', 'Flow Cell Failed', 'Failed Flow Cell'),
                'Flow Cell',
                arrays.array_desc
            ) as array_desc,
            arrays.array_layout_id,
            arrayitems.item_label as well_location,
            case
                {# 
                    This is an edge case where the array was set to all dashes. 
                    It's a cfDNA extraction plate. 
                #}
                when arrays.array_id = '----------'
                then 'cfDNA Extraction'
                else operation_name
            end as operation_name,
            iff(arrays.array_desc ilike '%Failed%', true, false) as is_failed_array,
            iff(arrayitemcontents.content_item = 'Control', true, false) is_control,
            arrayitems.created_by,
            arrayitems.modified_by as mod_by,
            arrayitems.created_at,
            arrayitems.modified_at as mod_at
        from arrays
        inner join arrayitems using (array_id)
        inner join arrayitemcontents using (array_item_id)
        left join operations using (array_id)
    ),
    main as (
        select
            array_id,
            array_item_id,
            sample_id,
            operation_name,
            array_desc,
            array_layout_id,
            well_location,
            is_control,
            is_failed_array,
            created_by,
            mod_by,
            created_at,
            mod_at
        from joined
    )

select *
from main
