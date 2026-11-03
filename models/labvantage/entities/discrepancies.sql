with
    sampledetail as (
        select
            s_sampleid as sample_id,
            detailvalue as discrepancy_reason,
            createdt as created_at,
            moddt as mod_at
        from {{ source("labvantage", "s_sampledetail") }}
    ),
    main as (
        select
            sample_id,
            case
                when
                    discrepancy_reason in (
                        'Patient age out of range',
                        'Tube arrived broken',
                        'Tube arrived leaking',
                        'Tube arrived frozen',
                        'Tube arrived too warm',
                        'Wrong number of tubes sent',
                        'Tube expired',
                        'Tube was not Streck',
                        'Tube expiration date unreadable',
                        'Sample passed seven-day stability window',
                        'Tube missing label',
                        'Tube label or barcode unreadable',
                        'Tube label did not match test requisition form',
                        'Test requisition form missing from shipment',
                        'Sample visibly compromised',
                        'Tube had insufficient volume',
                        'Samples sent to incorrect address',
                        'PHI was included in materials received'
                    )
                then 'whole_blood_discrepancy'
                when
                    discrepancy_reason in (
                        'Failed due to insufficient plasma',
                        'Failed due to lab issue',
                        'Failed due to sample being compromised',
                        'Order was cancelled by the patient',
                        'Order was cancelled by the site',
                        'Order was cancelled due to being a duplicate'
                    )
                then 'purified_plasma_discrepancy'
                else 'other_discrepancy'
            end as discrepancy_type,
            discrepancy_reason,
            created_at,
            mod_at
        from sampledetail
        {# 
            There's no rule against having the same discrepancy entered multiple times
            for the same sample. This dedupes those instances by taking the most recent
            copy. 
        #}
        qualify
            row_number() over (
                partition by sample_id, discrepancy_reason order by created_at desc
            )
            = 1
    )

select *
from main
