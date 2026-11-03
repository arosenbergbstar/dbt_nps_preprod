{#
    Test that FIO metrics have pass=true after cutoff date (DO-275).

    At the 2025-08-21 cutoff, only multicancer existed as a v2 pipeline.
    Pancv2 was added later, so all pancv2 results are inherently after cutoff.

    Note: If additional metrics become FIO in the future, this test will need
    updating with a different cutoff date for those metrics.
#}

select *
from {{ ref("stg_clinpipe__results_json_v2") }}

where
    modified_at > to_timestamp_tz('2025-08-21 00:00:00 -0700')
    and (
        is_pass_wgs_pcr_efficiency = false
        or is_pass_hmc_pcr_efficiency = false
        or is_pass_cfdna_extraction_efficiency = false
        or is_pass_hmc_prepcr_lib_hg_dna_ng = false
        or is_pass_wgs_mass_ratio_error_factor = false
        or is_pass_wgs_prepcr_lib_hg_dna_ng = false
    )
