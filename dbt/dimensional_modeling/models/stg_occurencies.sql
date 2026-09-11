select 
     id as occurrenceId
    ,payload ->>'address' as endereco
    ,payload -> 'region' ->>'name' as regiao
    ,payload -> 'region' ->>'id' as regiao_id
    ,payload -> 'region'->>'state' as estado
    ,payload -> 'city' ->>'name' as cidade
    ,payload -> 'city' ->>'id' as cidade_id
    ,(payload ->> 'latitude')::numeric as latitude
    ,(payload ->> 'longitude')::numeric as longitude
    ,payload ->'contextInfo' -> 'mainReason' ->> 'name' as motivacao
    ,payload ->'contextInfo' -> 'mainReason' ->> 'id' as motivacao_id
    -- ,payload ->'contextInfo' -> 'clippings' ->> 'name' as tipo_crime
    ,payload ->'policeAction' as acao_policial
    ,payload ->'date' as data_ocorrencia
from {{source('fogo_cruzado','raw_ocorrencias')}}