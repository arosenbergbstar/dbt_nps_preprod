with
    {# 
        We prefer to link flow cell ID to its' chemistry (WGS or HMC)
        with the jobs table so that we do not have to calculate it
        within the model.
    #}
    jobs as (select hmc_flow_cell_id, wgs_flow_cell_id from {{ ref("stg_lv__job") }}),
    flowcell_chemistry_modern as (
        select distinct hmc_flow_cell_id as flowcell_id, 'hmc' as flowcell_process_type
        from jobs
        union
        select distinct wgs_flow_cell_id as flowcell_id, 'wgs' as flowcell_process_type
        from jobs
    ),
    {# 
        Older flowcells predate the jobs table and are not included within.
        For those flow cells, we must calculate the chemistry from transfer execution
        events.
    #}
    transfer_executions as (
        select
            transferexecutionid::varchar as transfer_execution_id,
            arraytransfermethodid::varchar as array_transfer_method_id,
            moddt::timestamp as mod_at
        from {{ source("labvantage", "transferexecution") }}
        where arraytransfermethodid = 'Sequencing 96 Well'
    ),
    transfer_execution_details as (
        select
            transferexecutionid::varchar as transfer_execution_id,
            transferexecutiondetailid::varchar as transfer_execution_detail_id,
            moddt::timestamp as mod_at,
            upper(sourcekeyid1::varchar) as source_array,
            upper(targetkeyid1::varchar) as target_array
        from {{ source("labvantage", "transferexecutiondetail") }}
    -- where target_array like 'H%'
    ),
    flowcell_chemistry_legacy as (
        select distinct
            transfer_execution_details.target_array flowcell_id,
            case
                left(transfer_execution_details.source_array, 1)
                when 'W'
                then 'wgs'
                when 'C'
                then 'hmc'
                else 'exception'
            end as flowcell_process_type
        from transfer_executions
        inner join transfer_execution_details using (transfer_execution_id)
        {#
            Excluding old TEST arrays, which fail unit tests.

            Excluding flow cell ids like 'HYM7%DMXX%', which are SDBB flow cells from 2021. The 
            pooling arrays are formatted as SDBB-CP######, also gets intepretted as 'exception'
            and fails the unit tests.
        #}
        where target_array not like '%TEST%' and target_array not like 'HYM7%DMXX%'
        qualify row_number() over (partition by target_array order by mod_at desc) = 1
    ),
    flowcell_chemistry as (
        select *
        from flowcell_chemistry_modern
        union
        select *
        from flowcell_chemistry_legacy
    )

select *
from flowcell_chemistry
