{% macro get_columns_regex(relation, regex) %}
    {% set columns = adapter.get_columns_in_relation(relation) %}
    {% set out_columns = [] %}
    {% for column in columns %}
        {% if modules.re.match(regex, column.name, modules.re.IGNORECASE) %}
            {{ out_columns.append(column.name) }}
        {% endif %}
    {% endfor %}
    {{ return(out_columns) }}
{% endmacro %}

{% macro get_columns_not_regex(relation, regex) %}
    {% set columns = adapter.get_columns_in_relation(relation) %}
    {% set out_columns = [] %}
    {% for column in columns %}
        {% if not modules.re.match(regex, column.name, modules.re.IGNORECASE) %}
            {{ out_columns.append(column.name) }}
        {% endif %}
    {% endfor %}
    {{ return(out_columns) }}
{% endmacro %}


{% macro airbyte_stg_source_cols(relation) %}
    {% set out_columns = [] %}
    {% for column in get_columns_not_regex(relation, "_AIRBYTE.*$") %}
        {{ out_columns.append(column) }}
    {% endfor %}
    {% for column in get_columns_regex(relation, "_AIRBYTE_EMITTED_AT") %}
        {{ out_columns.append(column) }}
    {% endfor %}
    {{ return(out_columns) }}
{% endmacro %}

{% macro unlist(list_of_lists) %}
    -- Takes a list of lists and appends all items into a single list
    {% set out_list = [] %}
    {% for l in list_of_lists %}
        {% if l is string %} {{ out_list.append(l) }}
        {% elif l is iterable %}
            {% for ll in l %} {{ out_list.append(ll) }} {% endfor %}
        {% endif %}
    {% endfor %}
    {{ return(out_list) }}
{% endmacro %}


{% macro list_diff(starting_list, lists_to_diff) %}
    -- This macro will take a starting list and remove all items that exist in
    -- lists_to_diff
    {% set out_list = [] %}
    {% set diff_list = unlist(lists_to_diff) %}
    {% for l in starting_list %}
        {% if l not in diff_list %} {{ out_list.append(l) }} {% endif %}
    {% endfor %}
    {{ return(out_list) }}
{% endmacro %}

{% macro airbyte_get_id_col(relation) %}
    {% set out_columns = [] %}
    {{ log(get_columns_regex(relation, ".*HASHID")) }}
    {{ out_columns.append(get_columns_regex(relation, ".*HASHID")) }}
    {{ out_columns.append(get_columns_regex(relation, ".*RAW_ID")) }}
    {{ return(unlist(out_columns)[0]) }}
{% endmacro %}

{% macro airbyte_get_emit_col(relation) %}
    {% set out_columns = [] %}
    {{ out_columns.append(get_columns_regex(relation, ".*EXTRACTED_AT")) }}
    {{ out_columns.append(get_columns_regex(relation, ".*EMITTED_AT")) }}
    {{ return(unlist(out_columns)[0]) }}
{% endmacro %}
