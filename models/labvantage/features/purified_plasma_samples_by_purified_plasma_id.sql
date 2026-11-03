with
    samples as (
        select *
        from {{ ref("samples") }}
        where
            iff(specimen_type is null, 'null', specimen_type)
            not in ('Hitachi Cup', 'Falcon Tube')
    ),

    samples_agg as (
        select distinct
            request_id,
            purified_plasma_id,
            study_id,
            study_site_description,
            source_sample_type_id,
            purified_plasma_volume
        from samples
        where
            purified_plasma_id is not null
            and sample_type_id
            in ('Purified Plasma', 'Pool', 'NTC', '5hmC Negative', '5hmC Positive')
            and (
                specimen_type is null
                or source_sample_type_id is null
                or sample_type_id = source_sample_type_id
            )
        {#
            Solves for cases where the source sample is purified_plasma but they generate
            a child purified plasma aliquot from it.

            If no child is generated you still need  to include the row with a sample_type is,
            but if there is a child you need to take the row(s) with NULL sample_type_id.
        #}
        qualify
            row_number() over (partition by purified_plasma_id order by sample_id desc)
            = 1
    ),

    collection_tube_type as (
        select distinct request_id, specimen_type
        from samples
        where
            sample_type_id = source_sample_type_id
            and specimen_type in ('EDTA', 'Streck BCT DNA')
    ),

    final as (
        select
            samples_agg.request_id,
            samples_agg.purified_plasma_id,
            samples_agg.study_id,
            samples_agg.study_site_description,
            samples_agg.source_sample_type_id,
            samples_agg.purified_plasma_volume,
            collection_tube_type.specimen_type as collection_tube_type
        from samples_agg
        left join
            collection_tube_type
            on samples_agg.request_id = collection_tube_type.request_id
    )

select *
from final
