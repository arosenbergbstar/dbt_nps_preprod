-- ("received", "received_at"),
{% set event_columns = [
    ("accessioned", "accessioned_at"),
    ("initial_report", "initial_report_at"),
    ("corrected_report", "corrected_report_at"),
    ("amended_report", "amended_report_at"),
    ("rejected", "rejected_at"),
    ("cancelled", "cancelled_at"),
] %}

with
    source as (select * from {{ ref("int_timestamps_by_trf_id") }}),

    pivoted as (

        {% for event_name, column_name in event_columns %}
            select
                trf_id,
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
        select trf_id, request_id, event_name, event_at
        from pivoted
        where event_at is not null
    )

select *
from final
