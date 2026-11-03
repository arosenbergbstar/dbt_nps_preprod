{% set src = source("labvantage", "u_bioclindeliverables") %}
with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("S_STUDYID") }} as study_id,
            {{ adapter.quote("DELIVERABLEID") }} as deliverable_id,
            {{ adapter.quote("BIOCLINDELIVERABLE") }} as bioclin_deliverable,

            {{ adapter.quote("USERSEQUENCE") }} as user_sequence,
            {{ adapter.quote("AUDITSEQUENCE") }} as audit_sequence,
            {{ adapter.quote("TRACELOGID") }} as trace_log_id,

            {{ adapter.quote("MODBY") }} as modified_by,
            {{ adapter.quote("MODDT") }} as modified_at,
            {{ adapter.quote("MODTOOL") }} as modified_tool,
            {{ adapter.quote("CREATEBY") }} as created_by,
            {{ adapter.quote("CREATEDT") }} as created_at,
            {{ adapter.quote("CREATETOOL") }} as created_tool,

            {{ airbyte_get_emit_col(src) }} as elt_emitted_at,
            {{ airbyte_get_id_col(src) }} as elt_hash_id

        from source
    ),
    typed as (
        select
            study_id::text as study_id,
            deliverable_id::text as deliverable_id,
            bioclin_deliverable::text as bioclin_deliverable,

            user_sequence::integer as user_sequence,
            audit_sequence::integer as audit_sequence,
            trace_log_id::text as trace_log_id,

            modified_by::text as modified_by,
            {{ cast_timestamp_tz("modified_at", "UTC") }},
            modified_tool::text as modified_tool,
            created_by::text as created_by,
            {{ cast_timestamp_tz("created_at", "UTC") }},
            created_tool::text as created_tool,

            elt_emitted_at::timestamp_tz as elt_emitted_at,
            elt_hash_id::text as elt_hash_id
        from renamed
    )
select *
from typed
