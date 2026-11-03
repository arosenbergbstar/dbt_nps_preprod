with
    arrayarraymethoditems as (
        select *
        from {{ source("labvantage", "arrayarraymethoditem") }}
        where
            arraymethodid rlike 'Flow Cell S. Kit.*'
            {# 
                Exclude FCs that are explicitly tests 
                or placeholder. This could be more explicit by 
                selecting IDs like 'H%', but the flowcell ID format
                could change in the future.
            #}
            and arrayid not like '%TEST%'
            and arrayid not like 'Pla%'
    ),

    main as (
        select distinct
            arrayid as flow_cell_id,
            arraymethodid as flow_cell_kit_description,
            regexp_substr(
                arraymethodid, 'Flow Cell (S.) Kit', 1, 1, 'e'
            ) as flow_cell_kit_id
        from arrayarraymethoditems
    )

select *
from main
