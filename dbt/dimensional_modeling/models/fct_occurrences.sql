with cnt_vitimas as (
    select
          count(victim_id) as n_vitimas
        , occurrence_id
    from 
        {{ref('stg_victims')}}    
    group by occurrence_id
)
,
cnt_mortos as (
    select
          count(victim_id) as n_mortos
        , occurrence_id
    from 
        {{ref('stg_victims')}}    
    where situacao = "Dead"
    group by occurrence_id
)
select 
      a.*
    , b.n_vitimas
    , c.n_mortos
from {{ref('stg_occurences')}} a 
left join cnt_vitimas b using(occurrence_id)
left join cnt_mortos c using(occurrence_id)