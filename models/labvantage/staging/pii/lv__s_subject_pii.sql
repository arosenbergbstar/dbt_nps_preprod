{{ config(post_hook="{{ dbt_snow_mask.apply_masking_policy('models') }}") }}
{% set src = source("labvantage", "s_subject") %}
with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("S_SUBJECTID") }} as subject_id,
            {{ adapter.quote("GENDERFLAG") }} as sex_at_birth,  {# this is intentional, the form in LV uses sex at birth#}
            {{ adapter.quote("U_IS_INFORMED") }} as has_informed_consent,
            {{ adapter.quote("U_DIABETESDIAGNOSISDT") }} as diabetes_diagnosed_date,
            {{ adapter.quote("U_BLOODDRAWAGE") }} as age_at_blood_draw,
            {{ adapter.quote("CDX_CLIENTID") }} as client_id,
            {{ adapter.quote("CDX_CLIENTADDRESSTYPE") }} as client_address_type,
            {{ adapter.quote("U_ORDERINGPHYSICIANNAME") }} as ordering_physician_name,
            {{ adapter.quote("U_BMI") }} as body_mass_index,
            {{ adapter.quote("U_IPMN") }} as ipmn,
            {{ adapter.quote("U_ETHNICITY") }} as ethnicity,
            {{ adapter.quote("U_ETHNICITYOTHER") }} as ethnicity_other,
            {{ adapter.quote("U_ICD10CODE") }} as icd_10_code,
            {{ adapter.quote("U_ICD10CODEOTHER") }} as icd_10_code_other,
            {{ adapter.quote("U_CHRONICPANC") }} as has_chronic_pancreatitis,
            {{ adapter.quote("U_SMOKER") }} as smoker,
            {{ adapter.quote("U_HEAVYSMOKER") }} as is_heavy_smoker,
            {{ adapter.quote("U_HISTORYOFPANC") }}
            as has_family_history_of_pancreatic_cancer,
            {{ adapter.quote("U_KNOWNRISKFACTORS") }} as known_genetic_risk_factors,
            {{ adapter.quote("U_RISKFACTORS") }} as has_risk_factors,
            {{ adapter.quote("U_OTHERCLINICALINFO") }} as other_clinical_info,

            {{ adapter.quote("MRN") }} as patient_medical_record_number,
            {{ adapter.quote("SUBJECTDESC") }} as patient_description,
            {{ adapter.quote("U_FIRSTNAME") }} as patient_first_name,
            {{ adapter.quote("U_MIDDLENAME") }} as patient_middle_name,
            {{ adapter.quote("U_LASTNAME") }} as patient_last_name,
            {{ adapter.quote("U_EMAIL") }} as patient_email,
            {{ adapter.quote("U_PHONENUMBER") }} as patient_phone_number,
            {{ adapter.quote("U_STREETADDRESS") }} as patient_address_street,
            {{ adapter.quote("U_CITY") }} as patient_address_city,
            {{ adapter.quote("U_STATE") }} as patient_address_state,
            {{ adapter.quote("U_ZIP") }} as patient_address_zip_code,
            {{ adapter.quote("BIRTHDT") }} as patient_birth_date,
            {{ adapter.quote("DEATHDT") }} as patient_death_date,

            {{ adapter.quote("SUBJECTTYPE") }} as subject_type,
            {{ adapter.quote("SPECIESID") }} as species_id,
            {{ adapter.quote("STRAINID") }} as strain_id,

            {{ adapter.quote("NOTES") }} as notes,
            {{ adapter.quote("USERSEQUENCE") }} as user_sequence,
            {{ adapter.quote("AUDITSEQUENCE") }} as audit_sequence,
            {{ adapter.quote("TEMPLATEFLAG") }} as is_from_template,
            {{ adapter.quote("ACTIVEFLAG") }} as is_active,
            {{ adapter.quote("TRACELOGID") }} as trace_log_id,

            {{ adapter.quote("MODBY") }} as modified_by,
            {{ adapter.quote("MODDT") }} as modified_at,
            {{ adapter.quote("CREATEBY") }} as created_by,
            {{ adapter.quote("CREATEDT") }} as created_at,

            {{ airbyte_get_emit_col(src) }} as elt_emitted_at,
            {{ airbyte_get_id_col(src) }} as elt_hash_id

        from source
    ),
    typed as (
        select
            subject_id::text as subject_id,
            {{ clean_gender("sex_at_birth") }}::text as sex_at_birth,
            has_informed_consent::boolean as has_informed_consent,
            diabetes_diagnosed_date::date as diabetes_diagnosed_date,
            age_at_blood_draw::number(38, 2) as age_at_blood_draw,
            client_id::text as client_id,
            ordering_physician_name::text as ordering_physician_name,
            body_mass_index::number(38, 2) as body_mass_index,
            ipmn::boolean as ipmn,
            smoker::text as smoker,
            is_heavy_smoker::boolean as is_heavy_smoker,
            ethnicity::text as ethnicity,
            ethnicity_other::text as ethnicity_other,
            icd_10_code::text as icd_10_code,
            icd_10_code_other::text as icd_10_code_other,
            has_chronic_pancreatitis::boolean as has_chronic_pancreatitis,
            has_family_history_of_pancreatic_cancer::boolean
            as has_family_history_of_pancreatic_cancer,
            has_risk_factors::boolean as has_risk_factors,
            known_genetic_risk_factors::text as known_genetic_risk_factors,
            other_clinical_info::text as other_clinical_info,
            patient_medical_record_number::text as patient_medical_record_number,
            patient_description::text as patient_description,
            patient_first_name::text as patient_first_name,
            patient_middle_name::text as patient_middle_name,
            patient_last_name::text as patient_last_name,
            patient_email::text as patient_email,
            patient_phone_number::text as patient_phone_number,
            patient_address_street::text as patient_address_street,
            patient_address_city::text as patient_address_city,
            patient_address_state::text as patient_address_state,
            patient_address_zip_code::text as patient_address_zip_code,
            patient_birth_date::date as patient_birth_date,
            patient_death_date::date as patient_death_date,
            subject_type::text as subject_type,

            notes::text as notes,
            user_sequence::integer as user_sequence,
            audit_sequence::integer as audit_sequence,
            is_from_template::boolean as is_from_template,
            is_active::boolean as is_active,
            trace_log_id::text as trace_log_id,

            modified_by::text as modified_by,
            {{ cast_timestamp_tz("modified_at", "UTC") }},
            created_by::text as created_by,
            {{ cast_timestamp_tz("created_at", "UTC") }},

            elt_emitted_at::timestamp_tz as elt_emitted_at,
            elt_hash_id::text as elt_hash_id
        from renamed
    )
select *
from typed
