with
    instruments as (
        select distinct
            samples.purified_plasma_id,
            instruments.instrument_type_id,
            instruments.array_method_id,
            instruments.instrument_id
        from {{ ref("array_items") }}
        inner join {{ ref("samples") }} using (sample_id)
        inner join {{ ref("instruments") }} using (array_id)
    ),
    instruments_deduped as (
        select
            purified_plasma_id,
            instrument_type_id,
            array_method_id,
            count(distinct instrument_id) as instrument_count,
            array_agg(distinct instrument_id) within group (
                order by instrument_id asc
            ) as instruments_list,
            max(instrument_id) as single_instrument
        from instruments
        group by 1, 2, 3
    ),
    main as (
        select
            purified_plasma_id,
            object_agg(
                concat(array_method_id, ' ', instrument_type_id),
                iff(
                    instrument_count = 1,
                    single_instrument::variant,
                    instruments_list::variant
                )
            ) as instruments
        from instruments_deduped
        group by 1
    )

select *
from main
