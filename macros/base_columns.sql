{% macro cast_timestamp_tz(
    ts_column, initial_time_zone, final_time_zone="America/Los_Angeles"
) %}
convert_timezone(
    '{{ final_time_zone }}',
    timestamp_tz_from_parts(
        year({{ ts_column }}::timestamp),
        month({{ ts_column }}::timestamp),
        day({{ ts_column }}::timestamp),
        hour({{ ts_column }}::timestamp),
        minute({{ ts_column }}::timestamp),
        second({{ ts_column }}::timestamp),
        date_part(nanosecond, {{ ts_column }}::timestamp),
        '{{ initial_time_zone }}'
    )
) as {{ ts_column }}
{% endmacro %}


{% macro clean_gender(col) %}
case
    when lower(trim({{ col }})) in ('m', 'male')
    then 'Male'
    when lower(trim({{ col }})) in ('f', 'female')
    then 'Female'
    when lower(trim({{ col }})) in ('u', 'unknown')
    then 'Unknown'
    else {{ col }}
end
{% endmacro %}

{% macro select_first_column(columns, relation) %}
{#-
This macro selects the first column from a list of columns that exists in a specified table.

:param columns: A list of columns to search from.
:param relation: The dbt relation to search in.

:return: A SQL query that selects the first column from the specified table.
-#}
{% set relation_columns = (
    adapter.get_columns_in_relation(relation) | map(attribute="name") | list
) %}
{# If you don't use the namespace func, the variable will be reset after the loop #}
{% set first_column = namespace(val=none) %}
{% for column in columns %}
{% if column in relation_columns %}
{% set first_column.val = column %} {% break %}
{% endif %}
{% endfor %}
{% if first_column.val is not none %} {{ adapter.quote(first_column.val) }}
{% else %} 0
{% endif %}
{% endmacro %}
