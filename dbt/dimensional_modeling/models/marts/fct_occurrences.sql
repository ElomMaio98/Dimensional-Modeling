with vitimas as (
    select
          occurrence_id
        , count(*) as n_vitimas
    from {{ source('core', 'victim') }}
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
    , b.neighborhood_name
    , c.name
    , coalesce(v.n_vitimas, 0)
    -- , neighborhood_id
    -- , main_reason_id
FROM {{source('core', 'occurrence')}} a  
LEFT JOIN {{ref('dim_locations')}} b on a.neighborhood_id=b.neighborhood_id
LEFT JOIN {{ref('dim_reason')}} c on c.id = a.main_reason_id
LEFT JOIN vitimas v on v.occurrence_id = a.id