{# v2 of the results json schema #}
{{ config(post_hook=["{{ apply_nodmed_row_access( this ) }}"]) }}

{% set src = source("clin_pipeline", "results") %}
{% set col_list = get_json_keys(src, "data") %}

with
    stg_study_samples as (
        select distinct sample_id, study_id from {{ ref("stg_study_samples") }}
    ),

    versioned_src as (
        select * from {{ ref("stg_clinpipe__legacy_versioned_results") }}
    ),

    {# here we have to handle the nested qc results introduced in v3 #}
    transformed_src as (
        select
            event,
            {{ rename_clia_pipeline("data", "clia_env_version") }},
            'pancreatic' as pipeline_name,
            {{ rename_clia_pipeline("data", "pipeline_version") }},
            {# expand the 5hmc_qc JSON data into individual columns #}
            {{ json_extract_scalar("data", ["5hmc_qc", "num_zero"]) }}
            as hmc_qc_num_zero,
            {{ json_extract_scalar("data", ["5hmc_qc", "perc_dup"]) }}
            as hmc_qc_perc_dup,
            {{ json_extract_scalar("data", ["5hmc_qc", "unique_fragments"]) }}
            as hmc_qc_unique_fragments,
            {{ json_extract_scalar("data", ["5hmc_qc", "zero_cpg"]) }}
            as hmc_qc_zero_cpg,
            {# expand the wgs_qc JSON data into individual columns #}
            {{ json_extract_scalar("data", ["wgs_qc", "num_zero"]) }}
            as wgs_qc_num_zero,
            {{ json_extract_scalar("data", ["wgs_qc", "perc_dup"]) }}
            as wgs_qc_perc_dup,
            {{ json_extract_scalar("data", ["wgs_qc", "unique_fragments"]) }}
            as wgs_qc_unique_fragments,
            {{ json_extract_scalar("data", ["wgs_qc", "zero_cpg"]) }}
            as wgs_qc_zero_cpg,
            {{ json_extract_scalar("data", ["wgs_qc", "mass_ratio_error_factor"]) }}
            as wgs_qc_mass_ratio_error_factor,
            {# expand the scores JSON data into individual columns #}
            {{ json_extract_scalar("data", ["scores", "pancreatic"]) }} as score_cancer,
            {{ rename_clia_pipeline("data", "b2f_version") }},
            {{ rename_clia_pipeline("data", "dna_id") }},
            {{ rename_clia_pipeline("data", "tissue_of_origin") }},
            {{ rename_clia_pipeline("data", "trf_id") }},
            hash_id,
            {{ rename_clia_pipeline("data", "job_id") }},
            emitted_at,
            {{ rename_clia_pipeline("data", "nf_b2f_version") }}
        from versioned_src
        where
            data:pipeline_name is null
            and major_pipeline_version = 3
            and minor_pipeline_version < 1
    ),

    final as (
        select transformed_src.*, stg_study_samples.study_id
        from transformed_src
        join stg_study_samples on stg_study_samples.sample_id = transformed_src.dna_id
    )

select *
from final
order by emitted_at asc, event asc
