{% macro generate_schema_name(custom_schema_name, node=none, override_target=none) -%}

    {%- set default_schema = target.schema -%}
    {%- set target_name = override_target or target.name -%}
    {%- if node is not none -%}
        {%- set config_database = node["config"].get("database") -%}

    {%- else -%} {%- set config_database = none -%}

    {%- endif -%}

    {%- if custom_schema_name is not none -%}

        {%- if target_name == "prod" -%} {{ custom_schema_name | trim }}

        {%- elif target_name in ["dev", "stage", "test"] -%}

            {%- if config_database is not none -%}

                {{ config_database }}_{{ custom_schema_name | trim }}

            {%- else -%} {{ custom_schema_name | trim }}

            {%- endif -%}

        {%- endif -%}

    {%- else -%} {{ default_schema }}

    {%- endif -%}

{%- endmacro %}


{% macro generate_database_name(custom_database_name=none, node=none) -%}

    {%- set default_database = target.database -%}
    {%- if custom_database_name is not none and target.name == "prod" -%}

        {{ custom_database_name | trim }}

    {%- else -%} {{ default_database }}

    {%- endif -%}

{%- endmacro %}
