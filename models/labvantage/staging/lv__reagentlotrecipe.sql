{% set src = source("labvantage", "reagentlotrecipe") %}

with
    source as (select * from {{ src }}),
    renamed as (
        select
            {{ adapter.quote("REAGENTLOTID") }} as reagent_lot_id,
            {{ adapter.quote("TRACKITEMID") }} as track_item_id,
            {{ adapter.quote("TRACKITEMREAGENTLOTID") }} as track_item_reagent_lot_id,
            {{ adapter.quote("ORIGINALREAGENTTYPEID") }} as original_reagent_type_id,
            {{ adapter.quote("REAGENTLOTRECIPEITEMID") }} as reagent_lot_recipe_item_id,

            {{ adapter.quote("AMOUNT") }} as amount,
            {{ adapter.quote("AMOUNTUNITS") }} as amount_units,
            {{ adapter.quote("AMOUNTTEXT") }} as amount_text,
            {{ adapter.quote("U_ADJFACTOR") }} as adjustment_factor,
            {{ adapter.quote("AMOUNTADJUSTED") }} as amount_adjusted,
            {{ adapter.quote("U_ADJCONCENTRATION") }} as adjusted_concentration,
            {{ adapter.quote("U_ADJCONCENTRATIONUNITS") }}
            as adjusted_concentration_units,
            {{ adapter.quote("RECIPEITEMTYPE") }} as recipe_item_type,
            {{ adapter.quote("AMOUNTUNITSTYPE") }} as amount_units_type,
            {{ adapter.quote("FILLTOVOLUMEFLAG") }} as fill_to_volume_flag,
            {{ adapter.quote("AMOUNTRECOMMENDED") }} as amount_recommended,
            {{ adapter.quote("AMOUNTRECOMMENDEDTEXT") }} as amount_recommended_text,
            {{ adapter.quote("AMOUNTRECOMMENDEDUNITS") }} as amount_recommended_units,
            {{ adapter.quote("INCLUDEDREAGENTLOTID") }} as included_reagent_lot_id,
            {{ adapter.quote("INCLUDEREAGENTTYPEID") }} as included_reagent_type_id,
            {{ adapter.quote("INSTRUMENTMANDATORYFLAG") }} as instrument_mandatory_flag,

            {{ adapter.quote("INSTRUMENTID") }} as instrument_id,
            {{ adapter.quote("INSTRUMENTTYPEID") }} as instrument_type_id,
            {{ adapter.quote("INSTRUMENTMODELID") }} as instrument_model_id,
            {{ adapter.quote("REAGENTLOTSTAGEID") }} as reagent_lot_stage_id,
            {{ adapter.quote("INSTRUMENTTYPE") }} as instrument_type,
            {{ adapter.quote("NGS_DEADVOLUME") }} as ngs_dead_volume,
            {{ adapter.quote("NGS_DEADVOLUMEUNIT") }} as ngs_dead_volume_unit,
            {{ adapter.quote("NGS_NUMSAMPLES") }} as ngs_num_samples,
            {{ adapter.quote("AMOUNTRECOMMENDEDUNITSTYPE") }}
            as amount_recommended_units_type,
            {{ adapter.quote("INCLUDEREAGENTTYPEVERSIONID") }}
            as included_reagent_type_version_id,
            {{ adapter.quote("ORIGINALREAGENTTYPEVERSIONID") }}
            as original_reagent_type_version_id,

            {{ adapter.quote("USERSEQUENCE") }} as user_sequence,
            {{ adapter.quote("AUDITSEQUENCE") }} as audit_sequence,
            {{ adapter.quote("TRACELOGID") }} as trace_log_id,

            {{ adapter.quote("MODBY") }} as modified_by,
            {{ adapter.quote("MODDT") }} as modified_at,
            {{ adapter.quote("CREATEBY") }} as created_by,
            {{ adapter.quote("CREATEDT") }} as created_at,

            {{ airbyte_get_emit_col(src) }} as elt_emitted_at,
            {{ airbyte_get_id_col(src) }} as elt_hash_id

        from source
    ),
    typed as (
        select
            reagent_lot_id::text as reagent_lot_id,
            track_item_id::text as track_item_id,
            track_item_reagent_lot_id::text as track_item_reagent_lot_id,
            original_reagent_type_id::text as original_reagent_type_id,
            reagent_lot_recipe_item_id::text as reagent_lot_recipe_item_id,

            amount::numeric(38, 10) as amount,
            amount_units::text as amount_units,
            amount_text::text as amount_text,
            adjustment_factor::numeric(38, 10) as adjustment_factor,
            amount_adjusted::numeric(38, 10) as amount_adjusted,
            adjusted_concentration::numeric(38, 10) as adjusted_concentration,
            adjusted_concentration_units::text as adjusted_concentration_units,
            recipe_item_type::text as recipe_item_type,
            amount_units_type::text as amount_units_type,
            amount_recommended::numeric(38, 10) as amount_recommended,
            amount_recommended_text::text as amount_recommended_text,
            amount_recommended_units::text as amount_recommended_units,
            included_reagent_lot_id::text as included_reagent_lot_id,
            included_reagent_type_id::text as included_reagent_type_id,

            instrument_id::text as instrument_id,
            instrument_type_id::text as instrument_type_id,
            instrument_model_id::text as instrument_model_id,
            reagent_lot_stage_id::text as reagent_lot_stage_id,
            instrument_type::text as instrument_type,
            ngs_dead_volume::numeric(38, 10) as ngs_dead_volume,
            ngs_dead_volume_unit::text as ngs_dead_volume_unit,
            ngs_num_samples::numeric(38, 10) as ngs_num_samples,
            amount_recommended_units_type::text as amount_recommended_units_type,
            included_reagent_type_version_id::text as included_reagent_type_version_id,
            original_reagent_type_version_id::text as original_reagent_type_version_id,
            instrument_mandatory_flag::text as instrument_mandatory_flag,
            fill_to_volume_flag::text as fill_to_volume_flag,

            user_sequence::numeric(38, 10) as user_sequence,
            audit_sequence::numeric(38, 10) as audit_sequence,
            trace_log_id::text as trace_log_id,

            modified_by::text as modified_by,
            {{ cast_timestamp_tz("modified_at", "UTC") }},
            created_by::text as created_by,
            {{ cast_timestamp_tz("created_at", "UTC") }},

            elt_emitted_at::timestamp as elt_emitted_at,
            elt_hash_id::text as elt_hash_id
        from renamed
    )
select *
from typed
