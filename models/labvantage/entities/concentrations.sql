with
    sdidataspecitem as (
        select * from {{ source("labvantage", "lv__sdidataitemspec") }}
    ),
    main as (
        select
            key_id_1,
            checked_value,
            sdc_id,
            condition,
            param_id,
            case
                spec_id
                when 'Concs_MCD_Test'
                then 'IVD_MCD'
                when 'Concs_LDT_PancV2'
                then 'LDT_PancV2'
                when 'Concs Ovarian'
                then 'LDT_ovarian'
                when 'Concs_BioClin'
                then 'bioclin'
                when 'Concentrations'
                then 'LDT_Panc'
            end as purified_plasma_test_id
        from sdidataspecitem
        where
            spec_id in (
                'Concs_MCD_Test',
                'Concs_LDT_PancV2',
                'Concs Ovarian',
                'Concs_BioClin',
                'Concentrations'
            )
            and checked_value is not null
        {# This logic needs to be replaced by the dataset column once it is available #}
        qualify
            row_number() over (
                partition by key_id_1, spec_id, param_id order by created_at desc
            )
            = 1
    )

select *
from main
