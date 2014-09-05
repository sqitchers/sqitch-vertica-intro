-- Deploy users
-- requires: appschema

CREATE TABLE flipr.users (
    nickname  VARCHAR      PRIMARY KEY,
    password  VARCHAR      NOT NULL,
    fullname  VARCHAR(256) NOT NULL,
    twitter   VARCHAR      NOT NULL,
    timestamp TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);
