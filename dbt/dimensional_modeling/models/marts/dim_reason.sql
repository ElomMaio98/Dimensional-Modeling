select
    row_number() over (order by name) as reason_key
    , name
    , id
FROM {{source('core','reason')}}