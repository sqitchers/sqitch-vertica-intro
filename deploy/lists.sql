-- Deploy lists
-- requires: appschema
-- requires: users

CREATE TABLE flipr.lists (
    nickname    VARCHAR2       NOT NULL REFERENCES flipr.users(nickname),
    name        VARCHAR2(256)  NOT NULL,
    description VARCHAR2(512)  NOT NULL,
    created_at  TIMESTAMPTZ    NOT NULL DEFAULT clock_timestamp()
);
