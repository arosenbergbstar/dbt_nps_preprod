{% set columns = dbt_utils.get_filtered_columns_in_relation(
    ref("stg_clia_pipeline__sequencing_run_metrics"), ["HASH_ID"]
) %}

{#
    Typing of the JSON-extracted metric columns ('None' -> null), carried over
    from dbt_prod clia_pipeline_sequencing_run_metrics.
#}
{% set float_columns = [
    "DEMUX_RATE",
    "DEMUX_BASEPAIR_YIELD_Q30_PCT",
    "TOTAL_READS_PF_PCT",
] %}
{% set number_columns = ["TOTAL_READS", "DEMUX_READS", "TOTAL_READS_PF"] %}
{% set string_columns = ["SEQUENCING_RUN_ID", "NF_B2F_VERSION"] %}

with
    stg_sequencing_run_metrics as (
        select * from {{ ref("stg_clia_pipeline__sequencing_run_metrics") }}
    ),

    final as (
        select
            {% for col in columns %}
                {% if col | upper in float_columns %}
                    iff("{{ col }}" = 'None', null, "{{ col }}"::float) as "{{ col }}"
                {% elif col | upper in number_columns %}
                    iff("{{ col }}" = 'None', null, "{{ col }}"::number) as "{{ col }}"
                {% elif col | upper in string_columns %}
                    iff("{{ col }}" = 'None', null, "{{ col }}"::string) as "{{ col }}"
                {% else %} "{{ col }}"
                {% endif %}
                {% if not loop.last %}, {% endif %}
            {% endfor %}
        from stg_sequencing_run_metrics
        qualify row_number() over (partition by hash_id order by emitted_at asc) = 1
    )

select *
from final
