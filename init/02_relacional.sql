CREATE SCHEMA IF NOT EXISTS core;

CREATE TABLE IF NOT EXISTS core.state (
    id    UUID PRIMARY KEY,
    name  TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS core.city (
    id        UUID PRIMARY KEY,
    name      TEXT NOT NULL,
    state_id  UUID NOT NULL REFERENCES core.state(id),
    UNIQUE (name, state_id)
);

CREATE TABLE IF NOT EXISTS core.neighborhood (
    id       UUID PRIMARY KEY,
    name     TEXT NOT NULL,
    city_id  UUID NOT NULL REFERENCES core.city(id),
    UNIQUE (name, city_id)
);

CREATE TABLE IF NOT EXISTS core.reason (
    id    UUID PRIMARY KEY,
    name  TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS core.clipping (
    id    UUID PRIMARY KEY,
    name  TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS core.genre (
    id    UUID PRIMARY KEY,
    name  TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS core.age_group (
    id    UUID PRIMARY KEY,
    name  TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS core.situation (
    id    SERIAL PRIMARY KEY,
    name  TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS core.person_type (
    id    SERIAL PRIMARY KEY,
    name  TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS core.occurrence (
    id               UUID PRIMARY KEY,
    document_number  INTEGER,
    occurred_at      TIMESTAMPTZ NOT NULL,
    address          TEXT,
    latitude         NUMERIC(12, 8),
    longitude        NUMERIC(12, 8),
    police_action    BOOLEAN NOT NULL,
    agent_presence   BOOLEAN NOT NULL,
    massacre         BOOLEAN NOT NULL,
    neighborhood_id  UUID NOT NULL REFERENCES core.neighborhood(id),
    main_reason_id   UUID REFERENCES core.reason(id)
);

CREATE TABLE IF NOT EXISTS core.victim (
    id              UUID PRIMARY KEY,
    occurrence_id   UUID NOT NULL REFERENCES core.occurrence(id),
    age             INTEGER,
    death_date      TIMESTAMPTZ,
    genre_id        UUID REFERENCES core.genre(id),
    age_group_id    UUID REFERENCES core.age_group(id),
    situation_id    INTEGER REFERENCES core.situation(id),
    person_type_id  INTEGER REFERENCES core.person_type(id)
);

CREATE TABLE IF NOT EXISTS core.occurrence_clipping (
    occurrence_id  UUID REFERENCES core.occurrence(id),
    clipping_id    UUID REFERENCES core.clipping(id),
    PRIMARY KEY (occurrence_id, clipping_id)
);

CREATE INDEX IF NOT EXISTS idx_city_state_id ON core.city (state_id);
CREATE INDEX IF NOT EXISTS idx_neighborhood_city_id ON core.neighborhood (city_id);
CREATE INDEX IF NOT EXISTS idx_occurrence_neighborhood_id ON core.occurrence (neighborhood_id);
CREATE INDEX IF NOT EXISTS idx_occurrence_main_reason_id ON core.occurrence (main_reason_id);
CREATE INDEX IF NOT EXISTS idx_occurrence_occurred_at ON core.occurrence (occurred_at);
CREATE INDEX IF NOT EXISTS idx_victim_occurrence_id ON core.victim (occurrence_id);