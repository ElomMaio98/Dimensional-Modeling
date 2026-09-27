with bounds as (
    select
          min(occurred_at)::date as minimum
        , max(occurred_at)::date as maximum
    from {{ source('core', 'occurrence') }}
    where occurred_at >='2016-01-01'
),
dates as (
    select generate_series(
        (select minimum from bounds),
        (select maximum from bounds),
        interval '1 day'
    )::date as date_day
)
select
    to_char(date_day, 'YYYYMMDD')::int as date_key
    , date_day 
    , extract(year from date_day) as year_date
    , extract(month from date_day) as month_num
    , extract(quarter from date_day) as quarter_num
    , to_char (date_day, 'Month') as month_nom
    , to_char (date_day, 'Day') as day_nom
    , case when extract(dow from date_day) in (5,6,0) then True else False end as weekend
from dates