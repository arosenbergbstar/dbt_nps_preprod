{# 
Adding or dropping them from columns are handled in the model yaml file
Modifying the policies themselves are trickier and must be updated in the macro
sql file `macros/snow-mask-ddl/pii_maskiing_policy.sql`. Here are the steps
1. Change the create statement you want to modify in the masking policy sql to `CREATE OR REPLACE`.
2. Run the command to unapply the masking policies. Make sure you run it for all 
model types that use the masking policies [sources, models, snapshots].
    ```
    dbt run-operation unapply_masking_policy --args '{"resource_type": "snapshots "}'
    ```
3. Run the command to create the masking policies.
    ```
    dbt run-operation create_masking_policy --args '{"resource_type": "snapshots "}'
    ```
4. Run the commmand to apply the masking policies. Make sure you run it for all
model types that use the masking policies [sources, models, snapshots].
    ```
    dbt run-operation apply_masking_policy --args '{"resource_type": "snapshots "}'
    ```
5. Change the create statement back to create if not exists so the create policies hook doesn't fail every run.
#}
{% macro create_masking_policy_mp_encrypt_pii_string(node_database, node_schema) %}

CREATE MASKING POLICY IF NOT EXISTS {{node_database}}.{{node_schema}}.mp_encrypt_pii_string AS (val string) 
  RETURNS string ->
      CASE 
        WHEN CURRENT_ROLE() IN ('LOADER_DEV', 'TRANSFORMER_DEV') THEN SHA2(val)
        WHEN array_contains('PII_ACCESS'::variant, parse_json(current_available_roles())) THEN val 
      ELSE '**********'
      END

{% endmacro %}

{% macro create_masking_policy_mp_encrypt_pii_date(node_database, node_schema) %}

CREATE MASKING POLICY IF NOT EXISTS {{node_database}}.{{node_schema}}.mp_encrypt_pii_date AS (val date) 
  RETURNS date ->
      CASE 
        WHEN CURRENT_ROLE() IN ('LOADER_DEV', 'TRANSFORMER_DEV') THEN (date_part("year", val) || '-01-01')::date
        WHEN array_contains('PII_ACCESS'::variant, parse_json(current_available_roles())) THEN val 
      ELSE to_date(to_timestamp_tz(0))
      END

{% endmacro %}

{% macro create_masking_policy_mp_encrypt_pii_bool(node_database, node_schema) %}

CREATE MASKING POLICY IF NOT EXISTS {{node_database}}.{{node_schema}}.mp_encrypt_pii_bool AS (val boolean) 
  RETURNS boolean ->
      CASE 
        WHEN CURRENT_ROLE() IN ('LOADER_DEV', 'TRANSFORMER_DEV') THEN null
        WHEN array_contains('PII_ACCESS'::variant, parse_json(current_available_roles())) THEN val 
      ELSE null
      END

{% endmacro %}

{% macro create_masking_policy_mp_encrypt_pii_int(node_database, node_schema) %}

CREATE MASKING POLICY IF NOT EXISTS {{node_database}}.{{node_schema}}.mp_encrypt_pii_int AS (val int) 
  RETURNS int ->
      CASE 
        WHEN CURRENT_ROLE() IN ('LOADER_DEV', 'TRANSFORMER_DEV') THEN 0
        WHEN array_contains('PII_ACCESS'::variant, parse_json(current_available_roles())) THEN val 
      ELSE 0
      END

{% endmacro %}

{% macro create_masking_policy_mp_encrypt_pii_number(node_database, node_schema) %}

CREATE MASKING POLICY IF NOT EXISTS {{node_database}}.{{node_schema}}.mp_encrypt_pii_number AS (val number) 
  RETURNS number ->
      CASE 
        WHEN CURRENT_ROLE() IN ('LOADER_DEV', 'TRANSFORMER_DEV') THEN 0
        WHEN array_contains('PII_ACCESS'::variant, parse_json(current_available_roles())) THEN val 
      ELSE 0
      END

{% endmacro %}

{% macro create_masking_policy_mp_encrypt_pii_variant(node_database, node_schema) %}

CREATE MASKING POLICY IF NOT EXISTS {{node_database}}.{{node_schema}}.mp_encrypt_pii_variant AS (val variant) 
  RETURNS variant ->
      CASE 
        WHEN CURRENT_ROLE() IN ('LOADER_DEV', 'TRANSFORMER_DEV') THEN parse_json('{"masked": "value"}')
        WHEN array_contains('PII_ACCESS'::variant, parse_json(current_available_roles())) THEN val 
      ELSE parse_json('{"masked": "value"}')
      END

{% endmacro %}

{% macro create_masking_policy_mp_encrypt_pii_timestamp(node_database, node_schema) %}

CREATE MASKING POLICY IF NOT EXISTS {{node_database}}.{{node_schema}}.mp_encrypt_pii_timestamp AS (val timestamp_tz) 
  RETURNS timestamp_tz ->
      CASE 
        WHEN CURRENT_ROLE() IN ('LOADER_DEV', 'TRANSFORMER_DEV') THEN to_timestamp_tz(0)
        WHEN array_contains('PII_ACCESS'::variant, parse_json(current_available_roles())) THEN val 
      ELSE to_timestamp_tz(0)
      END

{% endmacro %}
