{{ config(materialized="table") }}

with
    legacy_timestamps as (select * from {{ ref("legacy_timestamps") }}),
    pipeline_timestamps as (select * from {{ ref("pipeline_timestamps") }}),
    main as (
        select *
        from legacy_timestamps
        union
        select *
        from pipeline_timestamps
    )
select *
from main
