{% set src = source("clin_pipeline", "sequencing_run_metrics") %}
{% set col_list = get_json_keys(src, "data") %}

with
    raw_src as (select * from {{ src }}),

    renamed as (
        select
            event,
            {% for col in col_list %}
                {{ rename_clia_pipeline("data", col) }},
            {% endfor %}
            md5(data) as hash_id,
            emitted_at::timestamp_tz as emitted_at
        from raw_src
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
        from renamed
        qualify row_number() over (partition by hash_id order by emitted_at asc) = 1
    )

select *
from final
