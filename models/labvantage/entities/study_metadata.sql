with
    studies as (
        select
            study_id, study_type, patient_report_type, study_description, study_status
        from {{ ref("lv__s_study") }}
    ),
    {#
        Aggregates BioClin deliverables into a flat JSON array per study.
        Output: one row per study_id with bfx_deliverables as an ARRAY of strings.
        Used by ext_clinpipe__job_inputs to inject deliverables into pipeline input JSON.
    #}
    bioclin_deliverables as (
        select
            study_id,
            array_agg(bioclin_deliverable) within group (
                order by deliverable_id
            ) as bfx_deliverables
        from {{ ref("lv__u_bioclindeliverables") }}
        where bioclin_deliverable is not null
        group by study_id
    ),
    main as (select * from studies left join bioclin_deliverables using (study_id))

select *
from main
