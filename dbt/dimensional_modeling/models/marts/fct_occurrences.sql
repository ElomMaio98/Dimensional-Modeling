with vitimas as (
    select
          occurrence_id
        , count(*) as n_vitimas
        , count(*) filter (where s.name = 'Dead') as n_mortos
    from {{ source('core', 'victim') }} v
    left join {{ref('dim_situation')}} s on s.id = v.situation_id
    group by occurrence_id
)
SELECT  
      a.id as occurrence_id
    , document_number
    , occurred_at
    , to_char(occurred_at, 'YYYYMMDD')::int as date_key
    , address
    , latitude
    , longitude
    , police_action
    , agent_presence
    , massacre
    , b.location_key 
    , c.reason_key
    , coalesce(v.n_vitimas, 0) as n_vitimas
    , coalesce(v.n_mortos, 0) as n_mortos
    -- , neighborhood_id
    -- , main_reason_id
FROM {{source('core', 'occurrence')}} a  
LEFT JOIN {{ref('dim_locations')}} b on a.neighborhood_id=b.neighborhood_id
LEFT JOIN {{ref('dim_reason')}} c on c.id = a.main_reason_id
LEFT JOIN vitimas v on v.occurrence_id = a.id
where a.occurred_at >= '2016-01-01'