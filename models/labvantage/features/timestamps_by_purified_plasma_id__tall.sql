{% set event_columns = [
    ("collected", "collected_at"),
    ("received", "received_at"),
    ("cfdna_extraction_instrument", "cfdna_extraction_instrument_at"),
    ("cfdna_extraction", "cfdna_extraction_at"),
    ("cfdna_stock", "cfdna_stock_at"),
    ("cfdna_spectramax", "cfdna_spectramax_at"),
    ("cfdna_norm_plate", "cfdna_norm_plate_at"),
    ("cfdna_norm", "cfdna_norm_at"),
    ("library_prep", "library_prep_at"),
    ("wgs_library", "wgs_library_at"),
    ("wgs_stock", "wgs_stock_at"),
    ("wgs_spectramax", "wgs_spectramax_at"),
    ("wgs_norm_plate", "wgs_norm_plate_at"),
    ("wgs_norm", "wgs_norm_at"),
    ("wgs_pool", "wgs_pool_at"),
    ("wgs_sequencing", "wgs_sequencing_at"),
    ("hmc_label", "hmc_label_at"),
    ("hmc_library", "hmc_library_at"),
    ("hmc_stock", "hmc_stock_at"),
    ("hmc_spectramax", "hmc_spectramax_at"),
    ("hmc_norm_plate", "hmc_norm_plate_at"),
    ("hmc_norm", "hmc_norm_at"),
    ("hmc_pool", "hmc_pool_at"),
    ("hmc_sequencing", "hmc_sequencing_at"),
    ("flowcell_processing_completed", "flowcell_processing_completed_at"),
    ("cancelled", "cancelled_at"),
] %}

with
    source as (select * from {{ ref("int_timestamps_by_purified_plasma_id") }}),

    pivoted as (
        {% for event_name, column_name in event_columns %}
            select
                purified_plasma_id,
                request_id,
                '{{ event_name }}' as event_name,
                {{ column_name }} as event_at
            from source
            {% if not loop.last %}
                union all
            {% endif %}
        {% endfor %}

    ),

    final as (
        select purified_plasma_id, request_id, event_name, event_at
        from pivoted
        where event_at is not null
    )

select *
from final
