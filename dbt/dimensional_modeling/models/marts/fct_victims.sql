select 
    a.id
    , a.occurrence_id
    , a.age
    , b.genre_key
    , c.age_group_key
    , d.id as situation_id
    , e.id as person_type_id
    , g.location_key
    , to_char(f.occurred_at, 'YYYYMMDD')::int as date_key
    
from {{source('core','victim')}} a
left join {{ref('dim_genre')}} b on (a.genre_id = b.id)
left join {{ref('dim_age_group')}} c on (a.age_group_id = c.id)
left join {{ref('dim_situation')}} d on  (a.situation_id = d.id)
left join {{ref('dim_person_type')}} e on  (a.person_type_id = e.id)
left join {{source('core','occurrence')}} f on  (a.occurrence_id = f.id)
left join {{ref('dim_locations')}} g on f.neighborhood_id = g.neighborhood_id
where f.occurred_at >= '2016-01-01'