{#
    Outstanding differences between this model and rpt_lab_scorecard

    PancV2 - only outlier CNC4202608/620030700MS1 shows up in new view, not in old view
    IVD_MCD - 21 CSRN1 samples rejected/cancelled show up in new, not old OR shows up in old with no test ID
            - 1 OASIS sample cancelled shows up in new, not old
            - 1 PCDC sample cancelled shows up in new, not old
    Ovarian - PS006729 in old, not new. This sample is a known issue where a PSID was reused
            - A bunch of DRY run test samples in new not old - don't care about these. Some are labeled as commercial, should be changed to test
            - 1 PCDC sample cancelled shows up in new, not old (same one as IVD_MCD)
    LDT_Panc - PS006728-33, known issues where psids were repeated
            - 1 PCDC sample cancelled shows up in new, not old (same one as IVD_MCD)
            - A bunch of DRY run test samples and a few other test samples in new not old - don't care about these. Some are labeled as commercial, should be changed to test
#}



with
    purified_plasma_samples_agg as (
        select * from {{ ref("purified_plasma_samples_by_purified_plasma_id") }}
    ),

    labvantage_data__purified_plasma as (
        select
            purified_plasma_samples_agg.purified_plasma_id,
            requests.trf_id,
            subjects.patient_id_list,
            purified_plasma_samples_agg.study_id,
            study_metadata.study_type,
            study_metadata.patient_report_type,
            study_metadata.study_description,
            study_metadata.study_status,
            study_metadata.bfx_deliverables,
            extraction_order.extraction_order,
            purified_plasma_samples_agg.study_site_description,
            purified_plasma_samples_agg.source_sample_type_id,
            assigned_tests.purified_plasma_test_id,
            purified_plasma_samples_agg.purified_plasma_volume,
            cfdna_concentration_value,
            is_passing_cfdna_concentration,
            hmc_library_concentration_value,
            is_passing_hmc_library_concentration,
            wgs_library_concentration_value,
            is_passing_wgs_library_concentration,
            purified_plasma_samples_agg.collection_tube_type,
            sample_timestamps.collected_at,
            sample_timestamps.received_at,
            request_timestamps.accessioned_at,
            sample_timestamps.cfdna_extraction_instrument_at,
            sample_timestamps.cfdna_extraction_at,
            sample_timestamps.cfdna_stock_at,
            sample_timestamps.cfdna_spectramax_at,
            sample_timestamps.cfdna_norm_plate_at,
            sample_timestamps.cfdna_norm_at,
            sample_timestamps.library_prep_at,
            sample_timestamps.wgs_library_at,
            sample_timestamps.wgs_stock_at,
            sample_timestamps.wgs_spectramax_at,
            sample_timestamps.wgs_norm_plate_at,
            sample_timestamps.wgs_norm_at,
            sample_timestamps.wgs_pool_at,
            sample_timestamps.wgs_sequencing_at,
            sample_timestamps.hmc_label_at,
            sample_timestamps.hmc_library_at,
            sample_timestamps.hmc_stock_at,
            sample_timestamps.hmc_spectramax_at,
            sample_timestamps.hmc_norm_plate_at,
            sample_timestamps.hmc_norm_at,
            sample_timestamps.hmc_pool_at,
            sample_timestamps.hmc_sequencing_at,
            sample_timestamps.flowcell_processing_completed_at,
            request_timestamps.initial_report_at,
            request_timestamps.corrected_report_at,
            request_timestamps.amended_report_at,
            iff(requests.request_status = 'Denied', request_timestamps.rejected_at, null) as rejected_at,
            coalesce(sample_timestamps.cancelled_at, iff(requests.request_status = 'Cancelled', request_timestamps.cancelled_at, null)) as cancelled_at,
            is_cancelled_all_pp_aliquots,
            is_cancelled_all_wb_aliquots,
            tat.ctat_in_days,
            tat.btat_in_days,
            well_locations.well_location_cfdna_extraction_24_well,
            well_locations.well_location_stock,
            well_locations.well_location_spectramax,
            array_ids.arrays,
            instruments.instruments,
            reagent_lots.reagent_lots
        from purified_plasma_samples_agg
        left join
            {{ ref("study_metadata") }} as study_metadata
            on purified_plasma_samples_agg.study_id = study_metadata.study_id
        left join
            {{ ref("requests") }} as requests
            on purified_plasma_samples_agg.request_id = requests.request_id
        left join
            {{ ref("subjects") }} as subjects
            on requests.subject_id = subjects.subject_id
        left join
            {{ ref("assigned_tests_by_trf_id__tall") }} as assigned_tests
            on purified_plasma_samples_agg.request_id = assigned_tests.request_id
        left join
            {{ ref("extraction_order_purified_plasma_id__tall") }} as extraction_order
            on purified_plasma_samples_agg.purified_plasma_id
            = extraction_order.purified_plasma_id
        left join
            {{ ref("array_ids_by_purified_plasma_id__json") }} as array_ids
            on purified_plasma_samples_agg.purified_plasma_id
            = array_ids.purified_plasma_id
        left join
            {{ ref("well_locations_by_purified_plasma_id__flat") }} as well_locations
            on purified_plasma_samples_agg.purified_plasma_id
            = well_locations.purified_plasma_id
        left join
            {{ ref("timestamps_by_purified_plasma_id__flat") }} as sample_timestamps
            on purified_plasma_samples_agg.purified_plasma_id
            = sample_timestamps.purified_plasma_id
        left join
            {{ ref("timestamps_by_trf_id__flat") }} as request_timestamps
            on requests.trf_id = request_timestamps.trf_id
        left join 
            {{ ref("turnaround_times_by_trf_id__flat") }} as tat
            on requests.request_id = tat.request_id
        left join
            {{ ref("instruments_by_purified_plasma_id__json") }} as instruments
            on purified_plasma_samples_agg.purified_plasma_id
            = instruments.purified_plasma_id
        left join
            {{ ref("reagent_lots_by_purified_plasma_id__json") }} as reagent_lots
            on purified_plasma_samples_agg.purified_plasma_id
            = reagent_lots.purified_plasma_id
        left join
            {{ ref("concentration_metrics_by_purified_plasma_id__flat") }}
            as concentration_metrics
            on purified_plasma_samples_agg.purified_plasma_id
            = concentration_metrics.purified_plasma_id
            and assigned_tests.purified_plasma_test_id
            = concentration_metrics.purified_plasma_test_id
    ),
    {# 
        This table is intended to capture TRF IDs that are rejected before 
        a purified plasma aliquot is recorded.
    #}
    labvantage_data__rejected_requests as (
        select
            null as purified_plasma_id,
            requests.trf_id,
            subjects.patient_id_list,
            requests.study_id,
            study_metadata.study_type,
            study_metadata.patient_report_type,
            study_metadata.study_description,
            study_metadata.study_status,
            study_metadata.bfx_deliverables,
            null as extraction_order,
            null as study_site_description,
            null as source_sample_type_id,
            assigned_tests.purified_plasma_test_id,
            null as purified_plasma_volume,
            null as cfdna_concentration_value,
            null as is_passing_cfdna_concentration,
            null as hmc_library_concentration_value,
            null as is_passing_hmc_library_concentration,
            null as wgs_library_concentration_value,
            null as is_passing_wgs_library_concentration,
            null as collection_tube_type,
            sample_timestamps.collected_at,
            sample_timestamps.received_at,
            request_timestamps.accessioned_at,
            null as cfdna_extraction_instrument_at,
            null as cfdna_extraction_at,
            null as cfdna_stock_at,
            null as cfdna_spectramax_at,
            null as cfdna_norm_plate_at,
            null as cfdna_norm_at,
            null as library_prep_at,
            null as wgs_library_at,
            null as wgs_stock_at,
            null as wgs_spectramax_at,
            null as wgs_norm_plate_at,
            null as wgs_norm_at,
            null as wgs_pool_at,
            null as wgs_sequencing_at,
            null as hmc_label_at,
            null as hmc_library_at,
            null as hmc_stock_at,
            null as hmc_spectramax_at,
            null as hmc_norm_plate_at,
            null as hmc_norm_at,
            null as hmc_pool_at,
            null as hmc_sequencing_at,
            null as flowcell_processing_completed_at,
            null as initial_report_at,
            null as corrected_report_at,
            null as amended_report_at,
            request_timestamps.rejected_at,
            coalesce(
                sample_timestamps.cancelled_at, request_timestamps.cancelled_at
            ) as cancelled_at,
            is_cancelled_all_pp_aliquots,
            is_cancelled_all_wb_aliquots,
            null as ctat_in_days,
            null as btat_in_days,
            null as well_location_cfdna_extraction_24_well,
            null as well_location_stock,
            null as well_location_spectramax,
            null::object as arrays,
            null::object as instruments,
            null::object as reagent_lots
        from {{ ref("requests") }}
        inner join
            {{ ref("timestamps_by_trf_id__flat") }} as request_timestamps
            on requests.trf_id = request_timestamps.trf_id
            and coalesce(
                request_timestamps.rejected_at, request_timestamps.cancelled_at
            )
            is not null
        left join
            {{ ref("study_metadata") }} as study_metadata
            on requests.study_id = study_metadata.study_id
        left join
            {{ ref("subjects") }} as subjects
            on requests.subject_id = subjects.subject_id
        left join
            {{ ref("assigned_tests_by_trf_id__tall") }} as assigned_tests
            on requests.request_id = assigned_tests.request_id
        left join
            {{ ref("timestamps_by_purified_plasma_id__flat") }} as sample_timestamps
            on requests.request_id = sample_timestamps.request_id
        where requests.trf_id not in (select distinct trf_id from labvantage_data__purified_plasma)
    ),

    labvantage_data__jobs as (
        select
            jobs.job_id,
            jobs.purified_plasma_id,
            jobs.trf_id,
            jobs.hmc_flow_cell_id,
            hmc_flow_cell_kits.flow_cell_kit_id as hmc_flow_cell_kit_id,
            jobs.hmc_index_i5,
            jobs.hmc_index_i7,
            jobs.wgs_flow_cell_id,
            wgs_flow_cell_kits.flow_cell_kit_id as wgs_flow_cell_kit_id,
            jobs.wgs_index_i5,
            jobs.wgs_index_i7,
            {#
                These three volumes should probably
                be pulled from the same source as jobs
                gets them from and added to samples or
                another entity.
            #}
            jobs.buffer_top_off_vol,
            jobs.extraction_input_vol,
            jobs.extraction_elution_vol,
            jobs.purified_plasma_test as purified_plasma_test_id,
            jobs.pipeline_name,
            jobs.biomarkers
        from {{ ref("jobs") }} as jobs
        left join
            {{ ref("flow_cell_kits") }} as hmc_flow_cell_kits
            on jobs.hmc_flow_cell_id = hmc_flow_cell_kits.flow_cell_id
        left join
            {{ ref("flow_cell_kits") }} as wgs_flow_cell_kits
            on jobs.hmc_flow_cell_id = wgs_flow_cell_kits.flow_cell_id
    ),

    pipeline_results as (select * from {{ ref("sample_metrics") }}),
    pipeline_timestamps as (select * from {{ ref("timestamps_by_jobs__flat") }}),

    labvantage_data__consolidated as (
        select *
        from labvantage_data__purified_plasma
        union
        select *
        from labvantage_data__rejected_requests
    ),

    final as (
        select
            labvantage_data__consolidated.trf_id,
            labvantage_data__consolidated.purified_plasma_id,
            labvantage_data__jobs.job_id,
            coalesce(
                labvantage_data__consolidated.purified_plasma_test_id,
                labvantage_data__jobs.purified_plasma_test_id
            ) as purified_plasma_test_id,
            labvantage_data__consolidated.patient_id_list,
            labvantage_data__consolidated.study_id,
            labvantage_data__consolidated.study_type,
            labvantage_data__consolidated.patient_report_type,
            labvantage_data__consolidated.study_description,
            labvantage_data__consolidated.study_status,
            labvantage_data__consolidated.bfx_deliverables,
            labvantage_data__consolidated.extraction_order,
            labvantage_data__consolidated.study_site_description,
            labvantage_data__consolidated.source_sample_type_id,
            labvantage_data__consolidated.purified_plasma_volume,
            labvantage_data__consolidated.cfdna_concentration_value,
            labvantage_data__consolidated.is_passing_cfdna_concentration,
            labvantage_data__consolidated.hmc_library_concentration_value,
            labvantage_data__consolidated.is_passing_hmc_library_concentration,
            labvantage_data__consolidated.wgs_library_concentration_value,
            labvantage_data__consolidated.is_passing_wgs_library_concentration,
            labvantage_data__consolidated.collection_tube_type,
            labvantage_data__consolidated.ctat_in_days,
            labvantage_data__consolidated.btat_in_days,
            labvantage_data__consolidated.collected_at,
            labvantage_data__consolidated.received_at,
            labvantage_data__consolidated.accessioned_at,
            labvantage_data__consolidated.cfdna_extraction_instrument_at,
            labvantage_data__consolidated.cfdna_extraction_at,
            labvantage_data__consolidated.cfdna_stock_at,
            labvantage_data__consolidated.cfdna_spectramax_at,
            labvantage_data__consolidated.cfdna_norm_plate_at,
            labvantage_data__consolidated.cfdna_norm_at,
            labvantage_data__consolidated.library_prep_at,
            labvantage_data__consolidated.wgs_library_at,
            labvantage_data__consolidated.wgs_stock_at,
            labvantage_data__consolidated.wgs_spectramax_at,
            labvantage_data__consolidated.wgs_norm_plate_at,
            labvantage_data__consolidated.wgs_norm_at,
            labvantage_data__consolidated.wgs_pool_at,
            labvantage_data__consolidated.wgs_sequencing_at,
            labvantage_data__consolidated.hmc_label_at,
            labvantage_data__consolidated.hmc_library_at,
            labvantage_data__consolidated.hmc_stock_at,
            labvantage_data__consolidated.hmc_spectramax_at,
            labvantage_data__consolidated.hmc_norm_plate_at,
            labvantage_data__consolidated.hmc_norm_at,
            labvantage_data__consolidated.hmc_pool_at,
            labvantage_data__consolidated.hmc_sequencing_at,
            labvantage_data__consolidated.flowcell_processing_completed_at,
            labvantage_data__consolidated.initial_report_at,
            labvantage_data__consolidated.corrected_report_at,
            labvantage_data__consolidated.amended_report_at,
            labvantage_data__consolidated.rejected_at,
            labvantage_data__consolidated.cancelled_at,
            labvantage_data__consolidated.is_cancelled_all_pp_aliquots,
            labvantage_data__consolidated.is_cancelled_all_wb_aliquots,
            labvantage_data__consolidated.well_location_cfdna_extraction_24_well,
            labvantage_data__consolidated.well_location_stock,
            labvantage_data__consolidated.well_location_spectramax,
            labvantage_data__consolidated.arrays,
            labvantage_data__consolidated.instruments,
            labvantage_data__consolidated.reagent_lots,
            labvantage_data__jobs.hmc_flow_cell_id,
            labvantage_data__jobs.hmc_flow_cell_kit_id,
            labvantage_data__jobs.hmc_index_i5,
            labvantage_data__jobs.hmc_index_i7,
            labvantage_data__jobs.wgs_flow_cell_id,
            labvantage_data__jobs.wgs_flow_cell_kit_id,
            labvantage_data__jobs.wgs_index_i5,
            labvantage_data__jobs.wgs_index_i7,
            labvantage_data__jobs.buffer_top_off_vol,
            labvantage_data__jobs.extraction_input_vol,
            labvantage_data__jobs.extraction_elution_vol,
            labvantage_data__jobs.pipeline_name,
            labvantage_data__jobs.biomarkers,
            pipeline_results.* exclude (job_id),
            pipeline_timestamps.* exclude (job_id)
        from labvantage_data__consolidated
        left join
            labvantage_data__jobs
            on equal_null(
                labvantage_data__consolidated.trf_id, labvantage_data__jobs.trf_id
            )
            and (
                labvantage_data__consolidated.purified_plasma_id
                = labvantage_data__jobs.purified_plasma_id
            )
            and (
                labvantage_data__consolidated.purified_plasma_test_id
                = labvantage_data__jobs.purified_plasma_test_id
                or labvantage_data__consolidated.purified_plasma_test_id is null
            )
        left join pipeline_results using (job_id)
        left join pipeline_timestamps using (job_id)
    )

select *
from final
