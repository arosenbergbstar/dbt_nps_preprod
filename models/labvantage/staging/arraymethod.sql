{% set src = source("labvantage", "arraymethod") %}
{% set col_list = adapter.get_columns_in_relation(src) %}
with
    raw_src as (select * from {{ src }}),
    final as (
        select
            {% for col in col_list %}
                {% if col.name.endswith("DT") %}
                    {{ cast_timestamp_tz(col.name, "UTC") }},
                {% elif col.name.endswith("DATE") %}
                    {{ cast_timestamp_tz(col.name, "UTC") }},
                    {% elif "_AIRBYTE" not in col.name %} {{ col.name }},
                {% endif %}
            {% endfor %}
            {{ airbyte_get_emit_col(src) }}::timestamp_tz as elt_emitted_at
        from raw_src
    )
select *
from final
