select
    o.id as occurrence_id,
    v ->> 'id' as victim_id,
    (v ->> 'age')::int as idade,
    v ->> 'situation' as situacao,
    v -> 'genre' ->> 'name' as genero
    , v -> 'genre' ->> 'id' as genero_id
from {{ source('fogo_cruzado','raw_ocorrencias') }} o,
     jsonb_array_elements(o.payload -> 'victims') as v