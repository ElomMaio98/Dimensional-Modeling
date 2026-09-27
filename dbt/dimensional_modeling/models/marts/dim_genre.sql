select
    row_number() over (order by name) as genre_key
    , name
    , id
FROM {{source('core','genre')}}