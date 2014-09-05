-- Deploy flips
-- requires: appschema
-- requires: users

CREATE TABLE flipr.flips (
    id        AUTO_INCREMENT PRIMARY KEY ,
    nickname  VARCHAR        NOT NULL REFERENCES flipr.users(nickname),
    body      VARCHAR(180)   NOT NULL DEFAULT '',
    timestamp TIMESTAMPTZ    NOT NULL DEFAULT clock_timestamp()
);

