with
    instruments as (
        select distinct
            arrayid as array_id,
            instrumentid as instrument_id,
            instrumenttypeid as instrument_type_id,
            arraymethodid as array_method_id
        from {{ source("labvantage", "arrayarraymethoditem") }}
        where instrument_id is not null
    )

select *
from instruments
