with
    s_sample as (select * from {{ ref("s_sample") }}),
    job as (select * from {{ ref("lv__u_job") }}),

    final as (
        select
            s_sample.s_sampleid as sample_id,
            s_sample.samplefamilyid as sample_family_id,
            s_sample.requestid as request_id,
            s_sample.u_tubelabel as purified_plasma_id,
            job.job_id,
            s_sample.sstudyid as study_id
        from s_sample
        left join job on s_sample.u_tubelabel = job.purified_plasma_id
    )

select *
from final
