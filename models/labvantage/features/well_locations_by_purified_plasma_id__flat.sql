with
    array_items as (
        select s.purified_plasma_id, ai.*
        from {{ ref("array_items") }} as ai
        inner join {{ ref("samples") }} as s using (sample_id)
    )

select
    purified_plasma_id,
    max(
        iff(operation_name = 'cfDNA Extraction', well_location, null)
    ) as well_location_cfdna_extraction_24_well,
    max(
        iff(operation_name = 'cfDNA Stock', well_location, null)
    ) as well_location_stock,
    max(
        iff(operation_name = 'cfDNA Spectramax', well_location, null)
    ) as well_location_spectramax
from array_items
group by 1
