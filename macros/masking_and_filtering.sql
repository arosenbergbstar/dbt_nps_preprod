{% macro create_nodmed_row_access() %}
    create schema if not exists security;
    create row access policy if not exists security.nodmed_row_policy as (study_id varchar) returns boolean -> 
    array_contains('NODMED_ACCESS'::variant, parse_json(current_available_roles()))
    or study_id != 'NODMED';
{% endmacro %}

{% macro apply_nodmed_row_access(table) %}
begin
;
{% if is_incremental() %}
    alter table if exists {{ table }}
    drop all row access policies;
{% endif %}
    alter table {{ table }}
    add row access policy security.nodmed_row_policy on (study_id);
commit
;
{% endmacro %}


{% macro filter_snowmask_columns(relation) %}
{% set relation = ref(relation) %}
{% if execute %}
{% set node = (
    graph.nodes.values()
    | selectattr("resource_type", "in", ["model", "snapshot"])
    | selectattr("name", "equalto", relation.identifier)
    | list
).pop() %}
{% set masked_columns = [] %}
{% for col, config in node.columns.items() %}
{% if "masking_policy" in config.meta.keys() %}
{% do masked_columns.append(col) %}
{% endif %}
{% endfor %}
select
    {{
        dbt_utils.star(
            relation,
            except=masked_columns,
        )
    }}
from {{ relation }}
{% endif %}
{% endmacro %}
