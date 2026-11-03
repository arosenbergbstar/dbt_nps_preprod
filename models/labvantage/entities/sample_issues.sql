{# Clarity needed on business logic for these events #}
with
    issues_all as (select * from {{ ref("stg_audit_lab_issues") }}),
    issues_current as (select * from {{ ref("stg_lab_issues") }}),
    main as (
        select
            issues_all.request_id,
            issues_all.reviewed_at,
            issues_all.reviewed_by,
            iff(issues_current.request_id is not null, true, false) is_active_issue,
            case
                issues_all.approval_tag when 'U' then 'On Hold' when 'F' then 'Rejected'
            end issue_type
        from issues_all
        left join issues_current on issues_all.request_id = issues_current.request_id
        {#
            There is no restriction on noting the same issue twice. There are two cases 
            where this occurs. This logic dedupes those instances.
        #}
        qualify
            row_number() over (
                partition by issues_all.request_id, issue_type
                order by issues_all.reviewed_at asc
            )
            = 1
    )

select *
from main
