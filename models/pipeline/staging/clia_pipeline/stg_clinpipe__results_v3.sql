{# v3 of the results json schema #}

with
    versioned_src as (
        select * from {{ ref("int_clinpipe__legacy_versioned_results") }}
    ),

    transformed_src as (
        select
            event,
            {{ rename_clia_pipeline("data", "clia_env_version") }},
            {{ rename_clia_pipeline("data", "pipeline_name") }},
            {{ rename_clia_pipeline("data", "pipeline_version") }},
            {# expand the hmc_qc JSON data into individual columns #}
            {% for col in (
                "num_zero",
                "perc_dup",
                "unique_fragments",
                "zero_cpg",
            ) %}
                {{ json_extract_scalar("data", ["hmc_qc", col]) }}
                as "{{ 'HMC_QC_' ~ col.upper() | replace(' ', '_') }}",
            {% endfor %}
            {# expand the wgs_qc JSON data into individual columns #}
            {% for col in (
                "perc_dup",
                "mass_ratio_error_factor",
                "zero_cpg",
                "unique_fragments",
                "num_zero",
            ) %}
                {{ json_extract_scalar("data", ["wgs_qc", col]) }}
                as "{{ 'WGS_QC_' ~ col.upper() | replace(' ', '_') }}",
            {% endfor %}
            {{ rename_clia_pipeline("data", "score_cancer") }},
            {{ rename_clia_pipeline("data", "b2f_version") }},
            {{ rename_clia_pipeline("data", "dna_id") }},
            {{ rename_clia_pipeline("data", "tissue_of_origin") }},
            {{ rename_clia_pipeline("data", "trf_id") }},
            {{ rename_clia_pipeline("data", "job_id") }},
            {{ rename_clia_pipeline("data", "nf_b2f_version") }},
            hash_id,
            emitted_at
        from versioned_src
        where
            (
                data:pipeline_name = 'pancreatic'
                and major_pipeline_version = 3
                and minor_pipeline_version >= 1
            )
            or (data:pipeline_name = 'ovarian' and major_pipeline_version >= 0)
    ),

    final as (select * from transformed_src)

select *
from final
order by emitted_at asc, event asc
