{% set src = source("labvantage", "reagentlot") %}

with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("REAGENTLOTID") }} as reagent_lot_id,
            {{ adapter.quote("REAGENTTYPEID") }} as reagent_type_id,
            {{ adapter.quote("REAGENTTYPEVERSIONID") }} as reagent_type_version_id,
            {{ adapter.quote("VENDORITEMID") }} as vendor_item_id,
            {{ adapter.quote("CONTAINERTYPEID") }} as container_type_id,
            {{ adapter.quote("SUPPLIERADDRESSID") }} as supplier_address_id,
            {{ adapter.quote("MANUFACTURERLOT") }} as manufacturer_lot_id,
            {{ adapter.quote("MANUFACTURERADDRESSID") }} as manufacturer_address_id,

            {{ adapter.quote("REAGENTLOTDESC") }} as reagent_lot_desc,
            {{ adapter.quote("REAGENTCLASS") }} as reagent_class,
            {{ adapter.quote("REAGENTSTATUS") }} as reagent_status,
            {{ adapter.quote("DISPOSITION") }} as reagent_disposition,
            {{ adapter.quote("AMOUNTINITIAL") }} as amount_initial,
            {{ adapter.quote("AMOUNTINITIALUNITS") }} as amount_initial_units,
            {{ adapter.quote("CONTAINERSINITIAL") }} as containers_initial,

            {{ adapter.quote("TRACKITEMEXPIRYPERIODREQFLAG") }}
            as is_track_item_expiry_period_req,
            {{ adapter.quote("CAPAINCIDENTGENERATEDFLAG") }}
            as is_capa_incident_generated,
            {{ adapter.quote("MANAGECONTAINERINVENTORYFLAG") }}
            as is_manage_container_inventory,
            {{ adapter.quote("PURCHASEDFLAG") }} as is_purchased,
            {{ adapter.quote("REORDEREDFLAG") }} as is_reordered,
            {{ adapter.quote("EXPIRYNOTIFYFLAG") }} as is_expiry_notify,
            {{ adapter.quote("EXPIRYREORDEREDFLAG") }} as is_expiry_reordered,
            {{ adapter.quote("CERTIFICATIONREQFLAG") }} as is_certification_req,
            {{ adapter.quote("QUALITYSAMPLEREQFLAG") }} as is_quality_sample_req,
            {{ adapter.quote("EXPIRYWARNINGNOTIFYFLAG") }} as is_expiry_warning_notify,

            {{ adapter.quote("EXPIRYDT") }} as expires_at,
            {{ adapter.quote("REORDEREDDT") }} as reordered_at,
            {{ adapter.quote("EXPIRYWARNINGDT") }} as expiry_warning_at,

            {{ adapter.quote("SITEDEPARTMENTID") }} as site_department_id,
            {{ adapter.quote("TARGETCONCENTRATIONPARAMID") }}
            as target_concentration_param_id,
            {{ adapter.quote("ACTIVEMATERIALID") }} as active_material_id,
            {{ adapter.quote("PRODVARIANTID") }} as prod_variant_id,
            {{ adapter.quote("LEVELID") }} as level_id,
            {{ adapter.quote("PARENTID") }} as parent_id,
            {{ adapter.quote("SSTUDYID") }} as study_id,
            {{ adapter.quote("AMOUNTRECIPE") }} as amount_recipe,
            {{ adapter.quote("ASSIGNEDANALYST") }} as assigned_analyst,
            {{ adapter.quote("AMOUNTINITIALMIN") }} as amount_initial_min,
            {{ adapter.quote("AMOUNTINITIALMAX") }} as amount_initial_max,
            {{ adapter.quote("TRACKITEMUNITTYPE") }} as track_item_unit_type,
            {{ adapter.quote("MAXFREEZETHAWCOUNT") }} as max_freeze_thaw_count,
            {{ adapter.quote("ACTUALCONCENTRATION") }} as actual_concentration,
            {{ adapter.quote("SUPPLIERADDRESSTYPE") }} as supplier_address_type,
            {{ adapter.quote("TARGETCONCENTRATION") }} as target_concentration,
            {{ adapter.quote("WARNFREEZETHAWCOUNT") }} as warn_freeze_thaw_count,
            {{ adapter.quote("AMOUNTINITIALUNITSTYPE") }} as amount_initial_units_type,
            {{ adapter.quote("MANUFACTURERADDRESSTYPE") }} as manufacturer_address_type,
            {{ adapter.quote("PRODVARIANTLOTREFERENCE") }}
            as prod_variant_lot_reference,
            {{ adapter.quote("PERCENTOFTARGETCONCENTRATION") }}
            as percent_of_target_concentration,
            {{ adapter.quote("TARGETCONCENTRATIONPARAMTYPE") }}
            as target_concentration_param_type,
            {{ adapter.quote("CONTAINERTRACKINGFLAG") }} as container_tracking_flag,
            {{ adapter.quote("GRACEPERIODDT") }} as grace_period_dt,

            {{ adapter.quote("NOTES") }} as notes,
            {{ adapter.quote("USERSEQUENCE") }} as user_sequence,
            {{ adapter.quote("AUDITSEQUENCE") }} as audit_sequence,
            {{ adapter.quote("TEMPLATEFLAG") }} as is_template,
            {{ adapter.quote("ACTIVEFLAG") }} as is_active,
            {{ adapter.quote("CONTENTFLAG") }} as content_flag,
            {{ adapter.quote("TRACELOGID") }} as trace_log_id,

            {{ adapter.quote("MODBY") }} as modified_by,
            {{ adapter.quote("MODDT") }} as modified_at,
            {{ adapter.quote("CREATEBY") }} as created_by,
            {{ adapter.quote("CREATEDT") }} as created_at,
            {{ adapter.quote("RECEIVEDBY") }} as received_by,
            {{ adapter.quote("RECEIVEDDT") }} as received_at,
            {{ adapter.quote("MIXEDBY") }} as mixed_by,
            {{ adapter.quote("MIXEDDT") }} as mixed_at,

            {{ airbyte_get_emit_col(src) }} as elt_emitted_at,
            {{ airbyte_get_id_col(src) }} as elt_hash_id

        from source
    ),
    typed as (
        select
            reagent_lot_id::text as reagent_lot_id,
            reagent_type_id::text as reagent_type_id,
            reagent_type_version_id::text as reagent_type_version_id,
            vendor_item_id::text as vendor_item_id,
            container_type_id::text as container_type_id,
            supplier_address_id::text as supplier_address_id,
            manufacturer_lot_id::text as manufacturer_lot_id,
            manufacturer_address_id::text as manufacturer_address_id,

            reagent_lot_desc::text as reagent_lot_desc,
            reagent_class::text as reagent_class,
            reagent_status::text as reagent_status,
            reagent_disposition::text as reagent_disposition,
            amount_initial::numeric(38, 10) as amount_initial,
            amount_initial_units::text as amount_initial_units,
            containers_initial::numeric(38, 10) as containers_initial,
            is_track_item_expiry_period_req::boolean as is_track_item_expiry_period_req,
            is_capa_incident_generated::boolean as is_capa_incident_generated,
            is_manage_container_inventory::boolean as is_manage_container_inventory,
            is_purchased::boolean as is_purchased,
            is_reordered::boolean as is_reordered,
            is_expiry_notify::boolean as is_expiry_notify,
            is_expiry_reordered::boolean as is_expiry_reordered,
            is_certification_req::boolean as is_certification_req,
            is_quality_sample_req::boolean as is_quality_sample_req,
            is_expiry_warning_notify::boolean as is_expiry_warning_notify,
            expires_at::timestamp as expires_at,
            reordered_at::timestamp as reordered_at,
            expiry_warning_at::timestamp as expiry_warning_at,
            site_department_id::text as site_department_id,
            target_concentration_param_id::text as target_concentration_param_id,
            active_material_id::text as active_material_id,
            prod_variant_id::text as prod_variant_id,
            level_id::text as level_id,
            parent_id::text as parent_id,
            study_id::text as study_id,
            amount_recipe::numeric(38, 10) as amount_recipe,
            assigned_analyst::text as assigned_analyst,
            amount_initial_min::numeric(38, 10) as amount_initial_min,
            amount_initial_max::numeric(38, 10) as amount_initial_max,
            track_item_unit_type::text as track_item_unit_type,
            max_freeze_thaw_count::numeric(38, 10) as max_freeze_thaw_count,
            actual_concentration::numeric(38, 10) as actual_concentration,
            supplier_address_type::text as supplier_address_type,
            target_concentration::numeric(38, 10) as target_concentration,
            warn_freeze_thaw_count::numeric(38, 10) as warn_freeze_thaw_count,
            amount_initial_units_type::text as amount_initial_units_type,
            manufacturer_address_type::text as manufacturer_address_type,
            prod_variant_lot_reference::text as prod_variant_lot_reference,
            percent_of_target_concentration::numeric(
                38, 10
            ) as percent_of_target_concentration,
            target_concentration_param_type::text as target_concentration_param_type,
            container_tracking_flag::text as container_tracking_flag,
            grace_period_dt::timestamp as grace_period_dt,
            notes::text as notes,

            user_sequence::numeric(38, 10) as user_sequence,
            audit_sequence::numeric(38, 10) as audit_sequence,
            is_template::boolean as is_template,
            is_active::boolean as is_active,
            content_flag::text as content_flag,
            trace_log_id::text as trace_log_id,

            modified_by::text as modified_by,
            {{ cast_timestamp_tz("modified_at", "UTC") }},
            created_by::text as created_by,
            {{ cast_timestamp_tz("created_at", "UTC") }},
            received_by::text as received_by,
            {{ cast_timestamp_tz("received_at", "UTC") }},
            mixed_by::text as mixed_by,
            {{ cast_timestamp_tz("mixed_at", "UTC") }},
            elt_emitted_at::timestamp_tz as elt_emitted_at,
            elt_hash_id::text as elt_hash_id
        from renamed
    )
select *
from typed
