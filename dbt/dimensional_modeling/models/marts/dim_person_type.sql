select
    id
    , name
    -- , row_number() over (order by name) as reason_key
FROM {{source('core','person_type')}}