with
    samples as (
        select
            s_sampleid as sample_id,
            requestid as request_id,
            samplefamilyid as sample_family_id,
            u_tubelabel as purified_plasma_id,
            sstudyid as study_id,
            sampletypeid as sample_type_id,
            preptypeid as prep_type_id,
            specimentype as specimen_type,
            samplestatus as sample_status,
            u_purifiedplasmavol as purified_plasma_volume,
            u_shipper as shipper,
            u_temperature as temperature,
            u_trackingnumber as tracking_number,
            u_shipdate as shipped_at,
            receiveddt as received_at,
            confirmeddt as confirmed_at,
            disposaldt as disposal_at,
            cancelleddt as cancelled_at,
            createdt as create_at,
            moddt as mod_at
        from {{ ref("s_sample") }}
    ),
    samplefamilies as (
        select
            s_samplefamilyid as sample_family_id,
            collectiondt as collection_at,
            studysiteid as study_site_id,
            sampletypeid as sample_type_id
        from {{ ref("s_samplefamily") }}
    ),
    studysite as (
        select study_site_id, study_site_description
        from {{ ref("lv__s_studysite") }}
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
