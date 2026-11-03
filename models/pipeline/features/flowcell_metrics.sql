with
    {#
        Transformations recreated from the dbt_prod clia_pipeline_sequencing_run_metrics
        mart and its upstream dependencies (dim_flowcell_methods, fact_qc_thresholds,
        fact_qc_thresholds_summary, stg_lv__specparamlimits), limited to the columns
        this model outputs. The qc_flowcell_flag (dim_qc_flowcells seed) is not used
        here and was not migrated.
    #}
    sequencing_run_metrics as (
        select
            right(sequencing_run_id, 9) as flow_cell_id,
            case
                when demux_rate = 'None' then null else demux_rate::float
            end as demux_rate,
            case
                when demux_basepair_yield_q30_pct = 'None'
                then null
                else demux_basepair_yield_q30_pct::float
            end as demux_basepair_yield_q30_pct,
            case
                when total_reads = 'None' then null else total_reads::number
            end as total_reads,
            case
                when demux_reads = 'None' then null else demux_reads::number
            end as demux_reads,
            case
                when sequencing_run_id = 'None' then null else sequencing_run_id::string
            end as sequencing_run_id,
            case
                when total_reads_pf = 'None' then null else total_reads_pf::number
            end as total_reads_pf,
            case
                when total_reads_pf_pct = 'None'
                then null
                else total_reads_pf_pct::float
            end as total_reads_pf_pct,
            emitted_at
        from {{ ref("clia_pipeline__sequencing_run_metrics") }}
        where event != 'REMOVE'
        qualify
            row_number() over (
                partition by sequencing_run_id
                order by sequencing_run_id asc, emitted_at desc
            )
            = 1
    ),
    {# Recreated from dbt_prod stg_arrayarraymethoditems / dim_flowcell_methods #}
    flowcell_methods as (
        select
            arrayid::varchar as flowcell_id,
            cast(split(arraymethodid::varchar, '-')[0] as varchar) as flowcell_method,
            regexp_substr(flowcell_method, '(S[P124])') as flowcell_method_abbv
        from {{ ref("arrayarraymethoditem") }}
        where
            flowcell_method_abbv in ('SP', 'S1', 'S2', 'S4')
            and flowcell_id not like '%TEST%'
    ),
    {#
        Recreated from dbt_prod stg_lv__specparamlimits / fact_qc_thresholds /
        fact_qc_thresholds_summary for the flow cell metrics only. For these metrics
        the valid threshold row is the one with operator1 '>='.
    #}
    flowcell_thresholds_distinct as (
        select distinct
            lower(metric_name) as metric_name,
            regexp_substr(spec_id, '\((S[12P])\)') as flowcell_method,
            {{ map_workflow_type("workflow_type") }} as pipeline_name,
            metric_value1 as threshold_value
        from {{ ref("lv__specparamlimits") }}
        where
            operator1 = '>='
            and lower(metric_name)
            in ('demux_rate', 'demux_basepair_yield_q30_pct', 'total_reads_pf')
    ),
    qc_thresholds as (
        select
            flowcell_method,
            pipeline_name,
            sum(
                iff(metric_name = 'demux_rate', threshold_value, null)
            ) as demux_rate,
            sum(
                iff(metric_name = 'demux_basepair_yield_q30_pct', threshold_value, null)
            ) as demux_basepair_yield_q30_pct,
            sum(
                iff(metric_name = 'total_reads_pf', threshold_value, null)
            ) as total_reads_pf
        from flowcell_thresholds_distinct
        where flowcell_method is not null
        group by flowcell_method, pipeline_name
    ),
    seq_run_metrics as (
        select
            sequencing_run_metrics.sequencing_run_id,
            sequencing_run_metrics.flow_cell_id as flowcell_id,
            sequencing_run_metrics.demux_basepair_yield_q30_pct
            as demux_basepair_yield_q30_perc,
            sequencing_run_metrics.demux_rate,
            sequencing_run_metrics.demux_reads,
            sequencing_run_metrics.total_reads,
            sequencing_run_metrics.total_reads_pf,
            sequencing_run_metrics.total_reads_pf_pct,
            iff(
                sequencing_run_metrics.demux_rate >= qc_thresholds.demux_rate,
                true,
                false
            ) as has_passed_demux_rate,
            iff(
                sequencing_run_metrics.demux_basepair_yield_q30_pct
                >= qc_thresholds.demux_basepair_yield_q30_pct,
                true,
                false
            ) as has_passed_demux_basepair_yield_q30_perc,
            iff(
                sequencing_run_metrics.total_reads_pf >= qc_thresholds.total_reads_pf,
                true,
                false
            ) as has_passed_total_reads_pf
        from sequencing_run_metrics
        inner join
            flowcell_methods
            on flowcell_methods.flowcell_id = sequencing_run_metrics.flow_cell_id
        inner join
            qc_thresholds
            on qc_thresholds.flowcell_method = flowcell_methods.flowcell_method_abbv
    )

select *
from seq_run_metrics
