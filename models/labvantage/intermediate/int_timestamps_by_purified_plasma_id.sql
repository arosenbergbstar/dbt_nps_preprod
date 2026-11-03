with
    samples as (
        select
            *,
            date_trunc('second', received_at) as received_at_sec,
            date_trunc('second', source_sample_collection_at) as collected_at_sec,
            date_trunc('second', cancelled_at) as cancelled_at_sec
        from {{ ref("samples") }}
    ),
    array_items as (
        select *, date_trunc('second', created_at) as array_created_at_sec
        from {{ ref("array_items") }}
    ),
    tasks as (
        select
            *,
            date_trunc(
                'second', flowcell_processing_completed_at
            ) as flowcell_processing_completed_at_sec
        from {{ ref("tasks") }}
    ),
    sample_timestamps_pp as (
        select
            purified_plasma_id,
            request_id,
            min(received_at_sec) as received_at,
            min(collected_at_sec) as collected_at,
            min(cancelled_at_sec) as cancelled_at
        from samples
        where
            purified_plasma_id is not null
            {#
                Purified Plasma covers all samples. Exclude Falcon Tube and Hitachi Cup because those exist only
                for CA19-9 samples and are in addition to the normal Purified Plasma rows.
                NTC/Pool/5hmC Negative/5hmC Positive are control samples - NTC, HMN, FN, FP
            #}
            and sample_type_id
            in ('Purified Plasma', 'NTC', 'Pool', '5hmC Negative', '5hmC Positive')
            and (
                specimen_type is null
                or specimen_type not in ('Falcon Tube', 'Hitachi Cup')
            )
        group by 1, 2
    ),
    sample_timestamps_source as (
        select
            null as purified_plasma_id,
            request_id,
            min(received_at_sec) as received_at,
            min(collected_at_sec) as collected_at,
            min(cancelled_at_sec) as cancelled_at
        from samples
        where
            sample_type_id in ('Whole Blood', 'Plasma')
            and not exists (
                select 1
                from sample_timestamps_pp
                where samples.request_id = sample_timestamps_pp.request_id
            )
        group by 1, 2
    ),
    sample_timestamps as (
        select *
        from sample_timestamps_pp
        union
        select *
        from sample_timestamps_source
    ),
    array_item_timestamps as (
        select
            purified_plasma_id,
            min(
                iff(
                    operation_name = 'cfDNA Extraction Instrument',
                    array_created_at_sec,
                    null
                )
            ) as cfdna_extraction_instrument_at,
            min(
                iff(operation_name = 'cfDNA Extraction', array_created_at_sec, null)
            ) as cfdna_extraction_at,
            min(
                iff(operation_name = 'cfDNA Spectramax', array_created_at_sec, null)
            ) as cfdna_spectramax_at,
            min(
                iff(operation_name = 'cfDNA Stock', array_created_at_sec, null)
            ) as cfdna_stock_at,
            min(
                iff(operation_name = 'cfDNA Norm Plate', array_created_at_sec, null)
            ) as cfdna_norm_plate_at,
            min(
                iff(operation_name = 'cfDNA Norm', array_created_at_sec, null)
            ) as cfdna_norm_at,
            min(
                iff(operation_name = 'Library Prep', array_created_at_sec, null)
            ) as library_prep_at,
            min(
                iff(operation_name = 'WGS Library', array_created_at_sec, null)
            ) as wgs_library_at,
            min(
                iff(operation_name = '5hmC Label', array_created_at_sec, null)
            ) as hmc_label_at,
            min(
                iff(operation_name = 'WGS Stock', array_created_at_sec, null)
            ) as wgs_stock_at,
            min(
                iff(operation_name = 'WGS Norm Plate', array_created_at_sec, null)
            ) as wgs_norm_plate_at,
            min(
                iff(operation_name = 'WGS Spectramax', array_created_at_sec, null)
            ) as wgs_spectramax_at,
            min(
                iff(operation_name = 'WGS Norm', array_created_at_sec, null)
            ) as wgs_norm_at,
            min(
                iff(operation_name = 'WGS Pool', array_created_at_sec, null)
            ) as wgs_pool_at,
            min(
                iff(operation_name = '5hmC Library', array_created_at_sec, null)
            ) as hmc_library_at,
            min(
                iff(operation_name = '5hmC Spectramax', array_created_at_sec, null)
            ) as hmc_spectramax_at,
            min(
                iff(operation_name = '5hmC Norm Plate', array_created_at_sec, null)
            ) as hmc_norm_plate_at,
            min(
                iff(operation_name = '5hmC Stock', array_created_at_sec, null)
            ) as hmc_stock_at,
            min(
                iff(operation_name = '5hmC Norm', array_created_at_sec, null)
            ) as hmc_norm_at,
            min(
                iff(operation_name = '5hmC Pool', array_created_at_sec, null)
            ) as hmc_pool_at,
            min(
                iff(operation_name = 'WGS Sequencing', array_created_at_sec, null)
            ) as wgs_sequencing_at,
            min(
                iff(operation_name = '5hmC Sequencing', array_created_at_sec, null)
            ) as hmc_sequencing_at
        from array_items
        inner join samples using (sample_id)
        group by 1
    ),
    task_timestamps as (
        select
            purified_plasma_id,
            min(
                flowcell_processing_completed_at_sec
            ) as flowcell_processing_completed_at
        from tasks
        inner join samples using (sample_id)
        group by 1
    ),
    main as (
        select
            purified_plasma_id,
            request_id,
            collected_at,
            received_at,
            cfdna_extraction_instrument_at,
            cfdna_extraction_at,
            cfdna_stock_at,
            cfdna_spectramax_at,
            cfdna_norm_plate_at,
            cfdna_norm_at,
            library_prep_at,
            wgs_library_at,
            wgs_stock_at,
            wgs_spectramax_at,
            wgs_norm_plate_at,
            wgs_norm_at,
            wgs_pool_at,
            wgs_sequencing_at,
            hmc_label_at,
            hmc_library_at,
            hmc_stock_at,
            hmc_spectramax_at,
            hmc_norm_plate_at,
            hmc_norm_at,
            hmc_pool_at,
            hmc_sequencing_at,
            flowcell_processing_completed_at,
            cancelled_at
        from sample_timestamps
        left join array_item_timestamps using (purified_plasma_id)
        left join task_timestamps using (purified_plasma_id)
    )

select *
from main
