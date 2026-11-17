with
    requests as (select * from {{ ref("lv__s_request") }}),
    sdiapprovalstep as (
        select
            key_id_1 request_id,
            approval_flag approval_tag,
            notes rejection_notes,
            reviewed_at rejected_at,
            reviewed_by
        from {{ ref("lv__sdiapprovalstep") }}
        where
            sdc_id = 'Request'
            and approval_type_id = 'RequestAcceptance'
            -- U means pending, the note is required for on hold
            and approval_flag = 'F'
    ),
    main as (
        select
            request_id,
            trf_id,
            subject_id,
            study_id,
            coalesce(work_item_id, 'LDT_Panc') as work_item_id,
            request_status,
            has_physician_signature,
            has_complete_data,
            study_arm,
            shipper,
            shipper_tracking_number,
            review_disposition,
            num_samples_expected,
            notes,
            samples_received_at,
            accessioned_at,
            requested_at,
            accepted_at,
            started_at,
            data_upload_at,
            released_at,
            due_at,
            hold_at,
            cancelled_at,
            rejected_at,
            created_at,
            modified_at,
            approval_tag,
            rejection_notes,
            reviewed_by
        from requests
        left join sdiapprovalstep using (request_id)
    )

select *
from main
