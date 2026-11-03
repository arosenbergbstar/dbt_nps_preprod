{# 
This is a set of macros to rename columns when iterating through them in a forloop
each should be named with rename_ then the model folder name
#}
{% macro clean_column_name(col) %}
    {% set out_column = modules.re.sub("^([^a-zA-Z_])", "_\g<1>", col.upper()) %}
    {% set out_column = modules.re.sub("([^a-zA-Z0-9_])", "_", out_column) %}
    {% set out_column = modules.re.sub("_+$", "", out_column) %}
    {{ return(out_column) }}
{% endmacro %}


{% macro rename_benchling(col) %}
    {% if col == "DESCRIPTIVE_NAME" %} descriptive_name as description
    {% elif col == "project_id$" %} "project_id$" as project_id
    {% elif col == "url$" %} "url$" as entity_url
    {% elif col == "archived$" %} "archived$"::boolean as is_archived
    {% elif col == "is_registered$" %} "is_registered$"::boolean as is_registered
    {% elif col == "validation_status$" %} "validation_status$" as validation_status
    {% elif col == "created_at$" %} "created_at$"::timestamp_tz as created_at
    {% elif col == "modified_at$" %} "modified_at$"::timestamp_tz as modified_at
    {% elif col == "_AIRBYTE_EMITTED_AT" %}
        _airbyte_emitted_at::timestamp_tz as emitted_at
    {% else %} "{{ col }}" as "{{col.upper()}}"
    {% endif %}
{% endmacro %}

{% macro rename_nftower(col) %}
    {% if col == "start" %} "start"::timestamp_tz as started_at
    {% elif col == "SUBMIT" %} submit::timestamp_tz as submitted_at
    {% elif col == "COMPLETE" %} complete::timestamp_tz as completed_at
    {% elif col == "DATE_CREATED" %} date_created::timestamp_tz as created_at
    {% elif col == "LAST_UPDATED" %} last_updated::timestamp_tz as updated_at
    {% else %} {{ col }}
    {% endif %}
{% endmacro %}

{% macro rename_rds_seq_metrics_etl(col) %}
    {% if col == "MULTIQC_TIMESTAMP" %}
        multiqc_timestamp::timestamp_tz as multiqc_timestamp
    {% elif col == "_AIRBYTE_EMITTED_AT" %}
        _airbyte_emitted_at::timestamp_tz as emitted_at
    {% else %} "{{ col }}" as {{ col.upper() }}
    {% endif %}
{% endmacro %}

{% macro rename_analysis_db(col, prefix=None) %}
    {% set col_join = (
        "_".join([prefix, col]).upper() if prefix is not none else col
    ) %}
    {% if col == "ID" %} "{{ col }}" as "{{ col_join }}"
    {% elif col == "REVISION" %} "{{ col }}" as "{{ col_join }}"
    {% elif col == "TAG" %} "{{ col }}" as "{{ col_join }}"
    {% elif col == "NAME" %} "{{ col }}" as "{{ col_join }}"
    {% elif col == "DESCRIPTION" %} "{{ col }}" as "{{ col_join }}"
    {% elif col == "_AIRBYTE_EMITTED_AT" %}
        _airbyte_emitted_at::timestamp_tz as emitted_at
    {% else %} "{{ col }}" as "{{col.upper()}}"
    {% endif %}
{% endmacro %}

{% macro rename_seq_run_metrics(col) %}
    -- interop_summary
    {% if col == "% >= Q30" %} {% set out_col = "PCT_CLUSTERS_PF_Q30" %}
    {% elif col == "% Aligned" %} {% set out_col = "PCT_ALIGNED" %}
    {% elif col == "% Occupied" %} {% set out_col = "PCT_OCCUPIED" %}
    {% elif col == "Yield G" %} {% set out_col = "YIELD_PF_GB" %}
    {% elif col == "Projected Yield G" %} {% set out_col = "PROJECTED_YIELD_PF_GB" %}
    -- interop_indexing
    {% elif col == "% Demux" %} {% set out_col = "PCT_DEMUX" %}
    {% else %} {% set out_col = col %}
    {% endif %}
    {{ json_extract_scalar("itemdata", [col]) }}
    as "{{ out_col.upper() | replace(' ', '_')}}"
{% endmacro %}

{% macro rename_sample_sheet_extra_columns(col) %}
    -- extra_columns
    {% if col == "% >= Q30" %} {% set out_col = "PCT_CLUSTERS_PF_Q30" %}
    {% elif col == "% Aligned" %} {% set out_col = "PCT_ALIGNED" %}
    {% elif col == "% Occupied" %} {% set out_col = "PCT_OCCUPIED" %}
    {% elif col == "Yield G" %} {% set out_col = "YIELD_PF_GB" %}
    {% elif col == "Projected Yield G" %} {% set out_col = "PROJECTED_YIELD_PF_GB" %}
    -- interop_indexing
    {% elif col == "% Demux" %} {% set out_col = "PCT_DEMUX" %}
    {% else %} {% set out_col = col %}
    {% endif %}
    nullif(
        {{ json_extract_scalar("extra_columns", [col]) }}, ''
    ) as "{{ clean_column_name(out_col) }}"
{% endmacro %}

{% macro rename_clia_pipeline(data_col, col) %}
    {# raw clin_pipeline #}
    {% if col.upper() == "JOBID" %} {% set out_col = "JOB_ID" %}
    {% else %} {% set out_col = col %}
    {% endif %}
    {% if col in ("saved", "moved") %}
        {# handle timestamps #}
        try_to_timestamp_tz(
            nullif({{ json_extract_scalar(data_col, [col]) }}::string, '')
        ) as "{{ out_col.upper() | replace(' ', '_')}}"
    {% elif col in ("sample_sheet_parsed") %}
        {# handle booleans #}
        try_to_boolean(
            {{ json_extract_scalar(data_col, [col]) }}
        ) as "{{ out_col.upper() | replace(' ', '_')}}"
    {% elif col.startswith("5hmc") %}
        {{ json_extract_scalar(data_col, [col]) }}
        as "{{ out_col.lstrip('5').upper() }}"
    {% else %}
        {{ json_extract_scalar(data_col, [col]) }}
        as "{{ out_col.upper() | replace(' ', '_') }}"
    {% endif %}
{% endmacro %}

{% macro rename_analytics(col) %}
    {% if col == "__HEVO__LOADED_AT" %}
        try_to_timestamp_tz(__hevo__loaded_at::string) as emitted_at
    {% elif col == "REPORT_DT" %} try_to_timestamp_tz(report_dt::string) as report_dt
    {% else %} "{{ col }}" as "{{col.upper()}}"
    {% endif %}
{% endmacro %}
