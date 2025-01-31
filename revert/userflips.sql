-- Deploy userflips
-- requires: appschema
-- requires: users
-- requires: flips

CREATE OR REPLACE VIEW flipr.userflips AS
SELECT f.id, u.nickname, u.fullname, f.body, f.timestamp
  FROM flipr.users u
  JOIN flipr.flips f ON u.nickname = f.nickname;
