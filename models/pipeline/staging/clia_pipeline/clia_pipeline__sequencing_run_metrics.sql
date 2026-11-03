with
    stg_sequencing_run_metrics as (
        select * from {{ ref("stg_clia_pipeline__sequencing_run_metrics") }}
    ),

    final as (
        select
            event,
            iff(demux_reads = 'None', null, demux_reads::number) as demux_reads,
            iff(total_reads = 'None', null, total_reads::number) as total_reads,
            stats,
            iff(
                sequencing_run_id = 'None', null, sequencing_run_id::string
            ) as sequencing_run_id,
            iff(demux_rate = 'None', null, demux_rate::float) as demux_rate,
            iff(
                total_reads_pf = 'None', null, total_reads_pf::number
            ) as total_reads_pf,
            iff(
                total_reads_pf_pct = 'None', null, total_reads_pf_pct::float
            ) as total_reads_pf_pct,
            iff(
                nf_b2f_version = 'None', null, nf_b2f_version::string
            ) as nf_b2f_version,
            fastq_manifest,
            iff(
                demux_basepair_yield_q30_pct = 'None',
                null,
                demux_basepair_yield_q30_pct::float
            ) as demux_basepair_yield_q30_pct,
            emitted_at
        from stg_sequencing_run_metrics
        qualify row_number() over (partition by hash_id order by emitted_at asc) = 1
    )

select *
from final
