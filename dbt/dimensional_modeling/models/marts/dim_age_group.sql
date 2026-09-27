select
    row_number() over (order by name) as age_group_key
    , name
    , id
FROM {{source('core','age_group')}}