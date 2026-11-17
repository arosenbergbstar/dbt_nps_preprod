with
    arrayarraymethoditems as (
        select *
        from {{ ref("lv__arrayarraymethoditem") }}
        where
            array_method_id rlike 'Flow Cell S. Kit.*'
            {# 
                Exclude FCs that are explicitly tests 
                or placeholder. This could be more explicit by 
                selecting IDs like 'H%', but the flowcell ID format
                could change in the future.
            #}
            and array_id not like '%TEST%'
            and array_id not like 'Pla%'
    ),

    main as (
        select distinct
            array_id as flow_cell_id,
            array_method_id as flow_cell_kit_description,
            regexp_substr(
                array_method_id, 'Flow Cell (S.) Kit', 1, 1, 'e'
            ) as flow_cell_kit_id
        from arrayarraymethoditems
    )

select *
from main
