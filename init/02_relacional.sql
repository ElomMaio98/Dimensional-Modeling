CREATE SCHEMA core;

CREATE TABLE core.estado(
    id UUID PRIMARY KEY,
    nome TEXT NOT NULL
);

CREATE TABLE core.motivo(
    id UUID PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE core.cidade(
    id UUID PRIMARY KEY,
    nome TEXT NOT NULL,
    estado_id UUID NOT NULL REFERENCES core.estado(id)
);

CREATE TABLE core.neighborhood(
    id UUID PRIMARY KEY,
    nome TEXT NOT NULL,
    cidade_id UUID NOT NULL REFERENCES core.cidade(id)
);

CREATE TABLE core.clipping(
    id UUID PRIMARY KEY,
    nome TEXT NOT NULL
);

CREATE TABLE core.genero(
    id UUID PRIMARY KEY,
    nome TEXT NOT NULL
);

CREATE TABLE core.faixa_etaria(
    id UUID PRIMARY KEY,
    nome TEXT NOT NULL
);

CREATE TABLE core.situacao(
    id SERIAL PRIMARY KEY,
    nome TEXT NOT NULL
);

CREATE TABLE core.civil(
    id SERIAL PRIMARY KEY,
    nome TEXT NOT NULL
);

CREATE TABLE core.ocorrencia(
    id UUID PRIMARY KEY
    , data_ocorrencia DATE NOT NULL
    , endereco TEXT NOT NULL
    , latitude NUMERIC NOT NULL
    , longitude NUMERIC NOT NULL
    , acao_policial BOOLEAN NOT NULL
    , presenca_agente BOOLEAN NOT NULL
    , massacre BOOLEAN NOT NULL
    , documento_numero TEXT NOT NULL
    , bairro_id UUID NOT NULL REFERENCES core.neighborhood(id)
    , motivo_id UUID REFERENCES core.motivo(id)
    -- , victim_id UUID NOT NULL REFERENCES core.neighborhood(id)
);

CREATE TABLE core.victims(
    id SERIAL PRIMARY KEY,
    idade INT,
    -- motivo_id UUID REFERENCES core.motivo(id)
    occurrence_id REFERENCES core.ocorrencia(id)
    , genero_id UUID REFERENCES core.genero(id)
    , faixa_etaria_id UUID REFERENCES core.faixa_etaria(id)
    , situacao_id INT REFERENCES core.situacao(id)
    , civil_id INT REFERENCES core.civil(id)
);

CREATE TABLE core.ocorrencia_clipping (
    ocorrencia_id UUID REFERENCES core.ocorrencia(id), 
    clipping_id UUID REFERENCES core.clipping(id), 
    PRIMARY KEY (ocorrencia_id, clipping_id)
)