with
    metrics as (
        select
            *,
            case
                condition when 'Pass' then true when 'Fail' then false else null
            end as is_passing
        from {{ ref("concentrations") }}
    ),
    eval as (
        select key_id_1, booland_agg(is_passing) as is_passing_lab_qc
        from metrics
        group by 1
    ),
    samples as (
        select sample_id, purified_plasma_id
        from {{ ref("samples") }}
        where purified_plasma_id is not null
    ),
    main as (
        select
            purified_plasma_id,
            purified_plasma_test_id,
            min(
                iff(param_id = 'cfDNA_conc_ng_ul', checked_value, null)
            ) as cfdna_concentration_value,
            min(
                iff(param_id = 'cfDNA_conc_ng_ul', is_passing, null)
            ) as is_passing_cfdna_concentration,
            min(
                iff(param_id = 'HMC_lib_conc_ng_ul', checked_value, null)
            ) as hmc_library_concentration_value,
            min(
                iff(param_id = 'HMC_lib_conc_ng_ul', is_passing, null)
            ) as is_passing_hmc_library_concentration,
            min(
                iff(param_id = 'WGS_lib_conc_ng_ul', checked_value, null)
            ) as wgs_library_concentration_value,
            min(
                iff(param_id = 'WGS_lib_conc_ng_ul', is_passing, null)
            ) as is_passing_wgs_library_concentration,
            min(is_passing_lab_qc) as is_passing_lab_qc
        from metrics
        inner join samples on key_id_1 = sample_id
        inner join eval using (key_id_1)
        group by 1, 2
    ),
    final as (
        select
            purified_plasma_id,
            purified_plasma_test_id,
            cfdna_concentration_value,
            is_passing_cfdna_concentration,
            hmc_library_concentration_value,
            is_passing_hmc_library_concentration,
            wgs_library_concentration_value,
            is_passing_wgs_library_concentration,
            is_passing_lab_qc
        from main
    )

select *
from final
