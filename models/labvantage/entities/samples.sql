with
    samples as (
        select
            sample_id,
            request_id,
            sample_family_id,
            tube_label as purified_plasma_id,
            sstudy_id as study_id,
            sample_type_id,
            prep_type_id,
            specimen_type,
            sample_status,
            purified_plasma_volume,
            shipper,
            temperature,
            tracking_number,
            ship_date as shipped_at,
            received_at,
            confirmed_at,
            disposed_at as disposal_at,
            cancelled_at,
            created_at as create_at,
            modified_at as mod_at
        from {{ ref("lv__s_sample") }}
    ),
    samplefamilies as (
        select
            sample_family_id,
            samples_collected_at as collection_at,
            study_site_id,
            sample_type_id
        from {{ ref("lv__s_samplefamily") }}
    ),
    studysite as (
        select study_site_id, study_site_description from {{ ref("lv__s_studysite") }}
    ),
    main as (
        select
            samples.sample_id,
            samples.request_id,
            samples.purified_plasma_id,
            samples.study_id,
            studysite.study_site_description,
            samples.sample_type_id,
            samplefamilies.sample_type_id as source_sample_type_id,
            samples.prep_type_id,
            samples.specimen_type,
            samples.sample_status,
            samples.purified_plasma_volume,
            samples.shipper,
            samples.temperature,
            samples.tracking_number,
            samplefamilies.collection_at source_sample_collection_at,
            samples.shipped_at,
            samples.received_at,
            samples.confirmed_at,
            samples.disposal_at,
            samples.cancelled_at,
            samples.create_at,
            samples.mod_at
        from samples
        left join samplefamilies using (sample_family_id)
        left join studysite using (study_site_id)
    )

select *
from main
