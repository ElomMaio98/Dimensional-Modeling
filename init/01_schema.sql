CREATE TABLE raw_ocorrencias(
    id UUID PRIMARY KEY,
    payload jsonb NOT NULL, -- utilizar jsonb porque ele é um formato mais adequado para extrair campos
    ingested_at TIMESTAMP DEFAULT NOW()

)
