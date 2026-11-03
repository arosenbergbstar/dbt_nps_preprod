{# Clarity needed on business logic for these events #}
with
    {#
        Transformations recreated from dbt_prod stg_audit_lab_issues (audit table)
        and stg_lab_issues (current table).
        U means pending, the note is required for on hold.
    #}
    issues_all as (
        select key_id_1 as request_id, approval_flag, reviewed_at, reviewed_by
        from {{ ref("lv__a_sdiapprovalstep") }}
        where
            (lower(notes) like '%on hold%' and approval_flag = 'U')
            or approval_flag = 'F'
    ),
    issues_current as (
        select key_id_1 as request_id
        from {{ ref("lv__sdiapprovalstep") }}
        where
            (lower(notes) like '%on hold%' and approval_flag = 'U')
            or approval_flag = 'F'
    ),
    main as (
        select
            issues_all.request_id,
            issues_all.reviewed_at,
            issues_all.reviewed_by,
            iff(issues_current.request_id is not null, true, false) is_active_issue,
            case
                issues_all.approval_flag when 'U' then 'On Hold' when 'F' then 'Rejected'
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
