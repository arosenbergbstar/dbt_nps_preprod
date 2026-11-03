with
    subject as (select * from {{ ref("stg_lv__s_subject_pii") }}),
    sdialias as (
        select source_entity_id as subject_id, alias_id
        from {{ ref("stg_lv__sdialias") }}
        where alias_id_type = 'patient id'
    ),
    patients as (
        select
            subject_id,
            listagg(alias_id, '|') within group (order by alias_id) as patient_id_list
        from sdialias
        group by 1
    ),
    main as (
        select
            subject_id,
            patients.patient_id_list,
            subject.patient_sex_at_birth,
            subject.has_informed_consent,
            subject.diabetes_diagnosed_date,
            subject.age_at_blood_draw,
            subject.modified_at,
            subject.created_at,
            subject.physician_full_name,
            subject.body_mass_index,
            subject.smoker,
            subject.patient_ethnicity,
            subject.icd_10_code,
            subject.is_heavy_smoker,
            subject.has_family_history_of_pancreatic_cancer,
            null as has_family_history_of_ovarian_cancer,
            subject.known_genetic_risk_factors
            as known_genetic_risk_factors__pancreatic,
            null as known_genetic_risk_factors,
            subject.has_risk_factors,
            subject.other_clinical_info,
            subject.notes
        from subject
        inner join patients using (subject_id)
    -- qualify
    -- row_number() over (
    -- partition by subject.subject_id order by subject.modified_at asc
    -- )
    -- = 1
    )

select *
from main
