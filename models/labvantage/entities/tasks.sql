with
    tasks as (
        select
            itemkeyid1 as sample_id,
            min(
                iff(taskdefid = 'Bluestar_FlowCell_Filter_Task', createdt, null)
            ) as flowcell_processing_completed_at
        from {{ ref("taskexecitem") }}
        {# 
            Bluestar_FlowCell_Filter_Task is the only task we currently use for
            analytics. This represents the step where a flowcell is processed 
            after pipeline is run and QC Metrics are approved. 
        #}
        where itemsdcid = 'Sample'
        group by 1
    )

select *
from tasks
