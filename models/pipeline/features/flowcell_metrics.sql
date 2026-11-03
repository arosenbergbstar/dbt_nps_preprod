with 
{# Naming and typesetting should ultimate be moved to BASE layer. #}
seq_run_metrics as (
        select 
            sequencing_run_id,
            flow_cell as flowcell_id,            
            demux_basepair_yield_q30_pct as demux_basepair_yield_q30_perc,
            demux_rate,
            demux_reads,
            total_reads, 
            total_reads_pf,
            total_reads_pf_pct,            
            has_passed_demux_rate::boolean as has_passed_demux_rate,
            has_passed_demux_basepair_yield_q30_perc::boolean as has_passed_demux_basepair_yield_q30_perc,
            has_passed_total_reads_pf::boolean as has_passed_total_reads_pf
        from {{ ref("clia_pipeline_sequencing_run_metrics") }}
    )

select * 
from seq_run_metrics