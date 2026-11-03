{#
    DO-459: Test edge case behavior for division by zero in v1 pipelines

    This test documents and verifies the expected behavior when
    hmc_unique_fragments = 0 (division by zero scenario).

    Only v1 pipelines (ovarian, pancreatic) perform the division calculation.
    v2 pipelines read the fraction directly from JSON.

    Expected behavior:
    - When unique_fragments = 0, hmc_zero_cpg_fraction should be NULL
    - This is correct because a fraction is mathematically undefined when denominator = 0
    - NULL indicates "sample failed / no data" rather than a valid measurement

    This test PASSES if:
    - All rows with hmc_unique_fragments = 0 have NULL for hmc_zero_cpg_fraction

    This test FAILS if:
    - Any row with hmc_unique_fragments = 0 has a non-NULL hmc_zero_cpg_fraction
      (would indicate incorrect handling of division by zero)
#}

select
    job_id,
    hmc_unique_fragments,
    hmc_zero_cpg_count,
    hmc_zero_cpg_fraction
from {{ ref("stg_clinpipe__results_json_v1") }}
where
    -- Find rows where unique_fragments is 0 or NULL
    (hmc_unique_fragments = 0 or hmc_unique_fragments is null)
    -- But fraction is NOT NULL (this would be a bug)
    and hmc_zero_cpg_fraction is not null
