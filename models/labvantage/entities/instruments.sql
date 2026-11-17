with
    instruments as (
        select distinct array_id, instrument_id, instrument_type_id, array_method_id
        from {{ ref("lv__arrayarraymethoditem") }}
        where instrument_id is not null
    )

select *
from instruments
