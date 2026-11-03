with
    source as (select * from {{ source("labvantage", "specparamlimits") }}),
    renamed as (
        select
            {{ adapter.quote("SPECID") }} as spec_id,
            {{ adapter.quote("PARAMLISTID") }} as param_list_id,
            {{ adapter.quote("VARIANTID") }} as workflow_type,
            {{ adapter.quote("PARAMTYPE") }} as param_type,
            {{ adapter.quote("LIMITTYPESEQUENCE") }} as limit_type_sequence,
            {{ adapter.quote("PARAMID") }} as metric_name,
            {{ adapter.quote("OPERATOR1") }} as operator1,
            {{ adapter.quote("VALUE1NUM") }} as metric_value1,
            {{ adapter.quote("OPERATOR2") }} as operator2,
            {{ adapter.quote("VALUE2NUM") }} as metric_value2
        from source
    ),
    typed as (
        select
            spec_id::varchar as spec_id,
            param_list_id::varchar as param_list_id,
            workflow_type::varchar as workflow_type,
            param_type::varchar as param_type,
            limit_type_sequence::int as limit_type_sequence,
            metric_name::varchar as metric_name,
            operator1::varchar as operator1,
            metric_value1::float as metric_value1,
            operator2::varchar as operator2,
            metric_value2::float as metric_value2
        from renamed
    )

select *
from typed
