{# v1 of the results json schema #}

{% set src = source("clin_pipeline", "results") %}
{% set col_list = get_json_keys(src, "data") %}

with
    versioned_src as (
        select * from {{ ref("int_clinpipe__legacy_versioned_results") }}
    ),

    transformed_src as (
        select
            event,
            {{ rename_clia_pipeline("data", "clia_env_version") }},
            'pancreatic' as pipeline_name,
            {{ rename_clia_pipeline("data", "pipeline_version") }},
            {# 5hmc qc #}
            {{ rename_clia_pipeline("data", "5hmc_qc_num_zero") }},
            {{ rename_clia_pipeline("data", "5hmc_qc_perc_dup") }},
            {{ rename_clia_pipeline("data", "5hmc_qc_unique_fragments") }},
            {{ rename_clia_pipeline("data", "5hmc_qc_zero_cpg") }},
            {# wgs qc #}
            {{ rename_clia_pipeline("data", "wgs_qc_num_zero") }},
            {{ rename_clia_pipeline("data", "wgs_qc_perc_dup") }},
            {{ rename_clia_pipeline("data", "wgs_qc_unique_fragments") }},
            {{ rename_clia_pipeline("data", "wgs_qc_zero_cpg") }},
            {{ rename_clia_pipeline("data", "wgs_qc_mass_ratio_error_factor") }},
            {# scores #}
            {{ json_extract_scalar("data", ["scores_pancreatic"]) }} as score_cancer,
            {{ rename_clia_pipeline("data", "b2f_version") }},
            {{ rename_clia_pipeline("data", "dna_id") }},
            {{ rename_clia_pipeline("data", "tissue_of_origin") }},
            {{ rename_clia_pipeline("data", "trf_id") }},
            {{ rename_clia_pipeline("data", "job_id") }},
            {{ rename_clia_pipeline("data", "nf_b2f_version") }},
            hash_id,
            emitted_at
        from versioned_src
        where pipeline_name is null and major_pipeline_version < 3
    ),

    final as (select * from transformed_src)

select *
from final
order by emitted_at asc, event asc
