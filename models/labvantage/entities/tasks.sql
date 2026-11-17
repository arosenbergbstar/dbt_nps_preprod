with
    tasks as (
        select
            item_key_id_1 as sample_id,
            min(
                iff(task_def_id = 'Bluestar_FlowCell_Filter_Task', created_at, null)
            ) as flowcell_processing_completed_at
        from {{ ref("lv__taskexecitem") }}
        {# 
            Bluestar_FlowCell_Filter_Task is the only task we currently use for
            analytics. This represents the step where a flowcell is processed 
            after pipeline is run and QC Metrics are approved. 
        #}
        where item_sdc_id = 'Sample'
        group by 1
    )

select *
from tasks
