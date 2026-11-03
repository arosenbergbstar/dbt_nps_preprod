{% macro get_json_keys(tbl, json_col) %}
    {% set query %}
    select distinct replace(replace(f.path, '[\'', ''), '\']', '') as "Path"
    from {{ tbl }},
    lateral flatten(
        coalesce(parse_json({{ json_col }}::text), {{ json_col }})::variant
    ) f
    {% endset %}
    {% set result = run_query(query) %}
    {# execute is a Jinja variable that returns True when dbt is in "execute" mode i.e. True when running dbt run but False during dbt compile. #}
    {% if execute %} {% set column_list = result.columns["Path"].values() %}
    {% else %} {% set column_list = [] %}
    {% endif %}

    {{ return(column_list) }}
{% endmacro %}
