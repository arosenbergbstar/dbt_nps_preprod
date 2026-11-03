with
    array_items as (
        select s.purified_plasma_id, ai.*
        from {{ ref("array_items") }} as ai
        inner join {{ ref("samples") }} as s using (sample_id)
    )

select
    purified_plasma_id,
    max(
        iff(operation_name = 'cfDNA Extraction Instrument', array_id, null)
    ) as cfdna_extraction_instrument_id,
    max(
        iff(operation_name = 'cfDNA Extraction', array_id, null)
    ) as cfdna_extraction_id,
    max(
        iff(operation_name = 'cfDNA Spectramax', array_id, null)
    ) as cfdna_spectramax_id,
    max(iff(operation_name = 'cfDNA Stock', array_id, null)) as cfdna_stock_id,
    max(
        iff(operation_name = 'cfDNA Norm Plate', array_id, null)
    ) as cfdna_norm_plate_id,
    max(iff(operation_name = 'cfDNA Norm', array_id, null)) as cfdna_norm_id,
    max(iff(operation_name = 'Library Prep', array_id, null)) as library_prep_id,
    max(iff(operation_name = 'WGS Library', array_id, null)) as wgs_library_id,
    max(iff(operation_name = '5hmC Label', array_id, null)) as hmc_label_id,
    max(iff(operation_name = 'WGS Stock', array_id, null)) as wgs_stock_id,
    max(iff(operation_name = 'WGS Norm Plate', array_id, null)) as wgs_norm_plate_id,
    max(iff(operation_name = 'WGS Spectramax', array_id, null)) as wgs_spectramax_id,
    max(iff(operation_name = 'WGS Norm', array_id, null)) as wgs_norm_id,
    max(iff(operation_name = 'WGS Pool', array_id, null)) as wgs_pool_id,
    max(iff(operation_name = '5hmC Library', array_id, null)) as hmc_library_id,
    max(iff(operation_name = '5hmC Spectramax', array_id, null)) as hmc_spectramax_id,
    max(iff(operation_name = '5hmC Norm Plate', array_id, null)) as hmc_norm_plate_id,
    max(iff(operation_name = '5hmC Stock', array_id, null)) as hmc_stock_id,
    max(iff(operation_name = '5hmC Norm', array_id, null)) as hmc_norm_id,
    max(iff(operation_name = '5hmC Pool', array_id, null)) as hmc_pool_id,
    max(iff(operation_name = 'WGS Sequencing', array_id, null)) as wgs_sequencing_id,
    max(iff(operation_name = '5hmC Sequencing', array_id, null)) as hmc_sequencing_id
from array_items
group by 1
