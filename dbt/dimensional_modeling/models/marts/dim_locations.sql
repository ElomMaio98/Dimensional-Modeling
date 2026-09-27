select 
    row_number() over (order by n.name asc) as location_key,
    n.id as neighborhood_id,
    n.name as neighborhood_name,
    c.name as city_name,
    s.name as state_name    
FROM {{source('core','neighborhood')}} n
LEFT JOIN {{source('core','city')}} c on n.city_id = c.id 
LEFT JOIN {{source('core','state')}} s on c.state_id = s.id