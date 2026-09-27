{{ config(severity = 'warn') }}

select * from {{ source('core', 'occurrence') }}
where occurred_at < '2016-01-01'