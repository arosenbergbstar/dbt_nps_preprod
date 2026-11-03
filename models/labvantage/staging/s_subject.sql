{% set src = source("labvantage", "s_subject") %}
with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("S_SUBJECTID") }} as subject_id,
            {{ adapter.quote("GENDERFLAG") }} as sex_at_birth,  {# this is intentional, the form in LV uses sex at birth#}
            {{ adapter.quote("U_IS_INFORMED") }} as has_informed_consent,
            {{ adapter.quote("U_DIABETESDIAGNOSISDT") }} as diabetes_diagnosed_at,
            {{ adapter.quote("U_BLOODDRAWAGE") }} as age_at_blood_draw,
            {{ adapter.quote("MODBY") }} as modified_by,
            {{ adapter.quote("MODDT") }} as modified_at,
            {{ adapter.quote("MODTOOL") }} as modified_with_tool,
            {{ adapter.quote("CREATEBY") }} as created_by,
            {{ adapter.quote("CREATEDT") }} as created_at,
            {{ adapter.quote("CREATETOOL") }} as created_with_tool,
            {{ adapter.quote("ACTIVEFLAG") }} as is_active,
            {{ adapter.quote("TRACELOGID") }} as trace_log_id,
            {{ adapter.quote("TEMPLATEFLAG") }} as is_from_template,
            {{ adapter.quote("USERSEQUENCE") }} as user_sequence,
            {{ adapter.quote("AUDITSEQUENCE") }} as audit_sequence,
            {{ adapter.quote("CDX_CLIENTID") }} as client_id,
            {{ adapter.quote("CDX_CLIENTADDRESSTYPE") }} as client_address_type,
            {{ adapter.quote("U_ORDERINGPHYSICIANNAME") }} as ordering_physician_name,
            {{ adapter.quote("U_BMI") }} as body_mass_index,
            {{ adapter.quote("U_IPMN") }} as ipmn,
            {{ adapter.quote("U_SMOKER") }} as smoker,
            {{ adapter.quote("U_ETHNICITY") }} as ethnicity,
            {{ adapter.quote("U_ETHNICITYOTHER") }} as ethnicity_other,
            {{ adapter.quote("U_ICD10CODE") }} as icd_10_code,
            {{ adapter.quote("U_ICD10CODEOTHER") }} as icd_10_code_other,
            {{ adapter.quote("U_CHRONICPANC") }} as has_chronic_pancreatitis,
            {{ adapter.quote("U_HEAVYSMOKER") }} as is_heavy_smoker,
            {{ adapter.quote("U_HISTORYOFPANC") }}
            as has_family_history_of_pancreatic_cancer,
            {{ adapter.quote("U_KNOWNRISKFACTORS") }} as known_genetic_risk_factors,
            {{ adapter.quote("U_RISKFACTORS") }} as risk_factors,
            {{ adapter.quote("U_OTHERCLINICALINFO") }} as other_clinical_info,
            {{ adapter.quote("NOTES") }} as notes,
            {{ airbyte_get_emit_col(src) }} as elt_emitted_at,
            {{ airbyte_get_id_col(src) }} as elt_hash_id

        from source
    ),
    typed as (
        select
            subject_id::text as subject_id,
            sex_at_birth::text as sex_at_birth,
            has_informed_consent::boolean as has_informed_consent,
            diabetes_diagnosed_at::timestamp_tz as diabetes_diagnosed_at,
            age_at_blood_draw::integer as age_at_blood_draw,
            modified_by::text as modified_by,
            {{ cast_timestamp_tz("modified_at", "UTC") }},
            modified_with_tool::text as modified_with_tool,
            created_by::text as created_by,
            {{ cast_timestamp_tz("created_at", "UTC") }},
            created_with_tool::text as created_with_tool,
            is_active::boolean as is_active,
            trace_log_id::text as trace_log_id,
            is_from_template::boolean as is_from_template,
            user_sequence::integer as user_sequence,
            audit_sequence::integer as audit_sequence,
            client_id::text as client_id,
            client_address_type::text as client_address_type,
            ordering_physician_name::text as ordering_physician_name,
            body_mass_index::float as body_mass_index,
            ipmn::text as ipmn,
            smoker::text as smoker,
            ethnicity::text as ethnicity,
            ethnicity_other::text as ethnicity_other,
            icd_10_code::text as icd_10_code,
            icd_10_code_other::text as icd_10_code_other,
            has_chronic_pancreatitis::boolean as has_chronic_pancreatitis,
            is_heavy_smoker::boolean as is_heavy_smoker,
            has_family_history_of_pancreatic_cancer::boolean
            as has_family_history_of_pancreatic_cancer,
            known_genetic_risk_factors::text as known_genetic_risk_factors,
            risk_factors::text as risk_factors,
            other_clinical_info::text as other_clinical_info,
            notes::text as notes,
            elt_emitted_at::timestamp_tz as elt_emitted_at,
            elt_hash_id::text as elt_hash_id
        from renamed
    )
select *
from typed
