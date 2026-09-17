select 
    id,
    nome
from {{ source('fogo_cruzado', 'raw_estados') }}