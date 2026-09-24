CREATE SCHEMA core;

CREATE TABLE core.state (
    id    UUID PRIMARY KEY,
    name  TEXT NOT NULL UNIQUE
);

CREATE TABLE core.city (
    id        UUID PRIMARY KEY,
    name      TEXT NOT NULL,
    state_id  UUID NOT NULL REFERENCES core.state(id),
    UNIQUE (name, state_id)
);

CREATE TABLE core.neighborhood (
    id       UUID PRIMARY KEY,
    name     TEXT NOT NULL,
    city_id  UUID NOT NULL REFERENCES core.city(id),
    UNIQUE (name, city_id)
);

CREATE TABLE core.reason (
    id    UUID PRIMARY KEY,
    name  TEXT NOT NULL
);

CREATE TABLE core.clipping (
    id    UUID PRIMARY KEY,
    name  TEXT NOT NULL
);

CREATE TABLE core.genre (
    id    UUID PRIMARY KEY,
    name  TEXT NOT NULL
);

CREATE TABLE core.age_group (
    id    UUID PRIMARY KEY,
    name  TEXT NOT NULL
);

CREATE TABLE core.situation (
    id    SERIAL PRIMARY KEY,
    name  TEXT NOT NULL UNIQUE
);

CREATE TABLE core.person_type (
    id    SERIAL PRIMARY KEY,
    name  TEXT NOT NULL UNIQUE
);

CREATE TABLE core.occurrence (
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

CREATE TABLE core.victim (
    id              UUID PRIMARY KEY,
    occurrence_id   UUID NOT NULL REFERENCES core.occurrence(id),
    age             INTEGER,
    death_date      TIMESTAMPTZ,
    genre_id        UUID REFERENCES core.genre(id),
    age_group_id    UUID REFERENCES core.age_group(id),
    situation_id    INTEGER REFERENCES core.situation(id),
    person_type_id  INTEGER REFERENCES core.person_type(id)
);

CREATE TABLE core.occurrence_clipping (
    occurrence_id  UUID REFERENCES core.occurrence(id),
    clipping_id    UUID REFERENCES core.clipping(id),
    PRIMARY KEY (occurrence_id, clipping_id)
);

CREATE INDEX ON core.city (state_id);
CREATE INDEX ON core.neighborhood (city_id);
CREATE INDEX ON core.occurrence (neighborhood_id);
CREATE INDEX ON core.occurrence (main_reason_id);
CREATE INDEX ON core.occurrence (occurred_at);
CREATE INDEX ON core.victim (occurrence_id);