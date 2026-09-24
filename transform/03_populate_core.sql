INSERT INTO core.state(id,name)
SELECT id,nome FROM public.raw_estados
ON CONFLICT (id) DO NOTHING;

INSERT INTO core.city (id,name,state_id)
SELECT 
     DISTINCT 
     cast(payload -> 'city' ->>'id' as UUID) AS id
    ,payload -> 'city' ->>'name' AS name
    ,cast(payload -> 'state' ->>'id' as UUID)  as state_id
FROM public.raw_ocorrencias
ON CONFLICT (id) DO NOTHING;

INSERT INTO core.neighborhood(id,name,city_id)
SELECT 
    DISTINCT
     cast(payload -> 'neighborhood' ->>'id' as UUID) AS id
    ,payload -> 'neighborhood' ->>'name' AS name
    ,cast(payload -> 'city' ->>'id' as UUID)  as city_id
FROM public.raw_ocorrencias
ON CONFLICT (id) DO NOTHING;

INSERT INTO core.reason (id,name)
SELECT
    DISTINCT
    cast(payload -> 'contextInfo'-> 'mainReason' ->>'id' as UUID) as id
    , payload -> 'contextInfo'-> 'mainReason' ->>'name' as reason
FROM public.raw_ocorrencias
ON CONFLICT (id) DO NOTHING;

INSERT INTO core.clipping(id,name)
SELECT 
    DISTINCT
    cast(v ->> 'id' AS UUID) AS id
    ,v ->> 'name' AS name
FROM public.raw_ocorrencias o,
    jsonb_array_elements(o.payload -> 'contextInfo' ->'clippings') as v
WHERE cast(v ->> 'id' AS UUID) IS NOT NULL AND
      v ->> 'name' IS NOT NULL
ON CONFLICT (id) DO NOTHING;

INSERT INTO core.genre(id,name)
SELECT 
    DISTINCT
    cast(v ->'genre' ->> 'id' AS UUID) AS id
    ,v ->'genre' ->> 'name' AS name
FROM public.raw_ocorrencias o,
    jsonb_array_elements(o.payload -> 'victims') as v
WHERE cast(v ->'genre' ->> 'id' AS UUID) IS NOT NULL AND
      v ->'genre' ->> 'name' IS NOT NULL
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

INSERT INTO core.age_group(id,name)
SELECT 
    DISTINCT
    cast(v ->'ageGroup' ->> 'id' AS UUID) AS id
    ,v ->'ageGroup' ->> 'name' AS name
FROM public.raw_ocorrencias o,
    jsonb_array_elements(o.payload -> 'victims' ) as v
WHERE cast(v ->'ageGroup' ->> 'id' AS UUID) IS NOT NULL AND
      v ->'ageGroup' ->> 'name' IS NOT NULL
ON CONFLICT (id) DO NOTHING;

INSERT INTO core.situation (name)
SELECT DISTINCT
    v ->> 'situation'
FROM public.raw_ocorrencias o,
     jsonb_array_elements(o.payload -> 'victims') AS v
WHERE v ->> 'situation' IS NOT NULL
ON CONFLICT (name) DO NOTHING;

INSERT INTO core.person_type(name)
SELECT 
    DISTINCT
    v ->> 'personType' AS name
FROM public.raw_ocorrencias o,
    jsonb_array_elements(o.payload -> 'victims' ) as v
WHERE v ->> 'personType' IS NOT NULL      
ON CONFLICT (name) DO NOTHING;


INSERT INTO core.occurrence(id,document_number, occurred_at, address, latitude,longitude, 
police_action,agent_presence,massacre,neighborhood_id,main_reason_id)
SELECT
    cast(payload ->> 'id' as UUID) as id
    , cast(payload ->> 'documentNumber' as int) as documentNumber
    , cast(payload ->>'date' as TIMESTAMPTZ) as date
    , payload ->> 'address'
    , cast(payload ->> 'latitude' as numeric) as latitude
    , cast(payload ->> 'longitude' as numeric) as longitude
    , cast(payload ->> 'policeAction' as boolean) as policeAction
    , cast(payload ->> 'agentPresence'as boolean) as agentPresence
    , cast(payload -> 'contextInfo' ->> 'massacre'as boolean) as massacre
    , cast(payload -> 'neighborhood' ->> 'id'as UUID) as neighborhoodId
    , cast(payload -> 'contextInfo' -> 'mainReason' ->> 'id'as UUID) as mainReasonId
FROM public.raw_ocorrencias 
ON CONFLICT (id) DO NOTHING;

INSERT INTO core.victim (id, occurrence_id, age, death_date, genre_id, age_group_id, situation_id, person_type_id)
SELECT
      cast(v ->> 'id' AS UUID)
    , cast(v ->> 'occurrenceId' AS UUID)
    , cast(v ->> 'age' AS INT)
    , cast(v ->> 'deathDate' AS TIMESTAMPTZ)
    , cast(v -> 'genre' ->> 'id' AS UUID)
    , cast(v -> 'ageGroup' ->> 'id' AS UUID)
    , s.id
    , p.id
FROM public.raw_ocorrencias o,
     jsonb_array_elements(o.payload -> 'victims') AS v
LEFT JOIN core.situation   s ON s.name = v ->> 'situation'
LEFT JOIN core.person_type p ON p.name = v ->> 'personType'
ON CONFLICT (id) DO NOTHING;

INSERT INTO core.occurrence_clipping (occurrence_id, clipping_id)
SELECT DISTINCT
      cast(o.payload ->> 'id' AS UUID)
    , cast(c ->> 'id' AS UUID)
FROM public.raw_ocorrencias o,
     jsonb_array_elements(o.payload -> 'contextInfo' -> 'clippings') AS c
ON CONFLICT (occurrence_id, clipping_id) DO NOTHING;