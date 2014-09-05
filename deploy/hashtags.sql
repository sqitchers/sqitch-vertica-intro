-- Deploy hashtags
-- requires: appschema
-- requires: flips

CREATE TABLE flipr.hashtags (
    flip_id   BIGINT  NOT   NULL REFERENCES flipr.flips(id),
    hashtag   VARCHAR(128)  NOT NULL,
    PRIMARY KEY (flip_id, hashtag)
);

