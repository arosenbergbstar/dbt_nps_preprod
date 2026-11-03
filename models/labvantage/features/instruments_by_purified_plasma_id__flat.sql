with
    array_items as (
        select s.purified_plasma_id, ai.*
        from {{ ref("array_items") }} as ai
        inner join {{ ref("samples") }} as s using (sample_id)
    )

select
    purified_plasma_id,
    max(iff(instrument_type_id = 'Qubit', instrument_id, null)) as qubit_instrument,
    max(
        iff(instrument_type_id = 'Microplate Reader', instrument_id, null)
    ) as microplate_reader_instrument,
    max(
        iff(instrument_type_id = 'Sequencer', instrument_id, null)
    ) as sequencer_instrument,
    max(
        iff(instrument_type_id = 'Liquid Handler', instrument_id, null)
    ) as liquid_handler_instrument,
    max(
        iff(instrument_type_id = 'ThermoCycler', instrument_id, null)
    ) as thermocycler_instrument
from array_items
inner join {{ ref("instruments") }} using (array_id)
group by 1
