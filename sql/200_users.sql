/* We wanna store the password in a private schema, because Postgraphile likes to use full table selects */
CREATE TABLE app_public.User (
  id          text PRIMARY KEY,
  email       text NOT NULL,
  data        jsonb,
  created_by  text,
  updated_by  text,
  created_at  timestamp,
  updated_at  timestamp,
  UNIQUE (email)
);


CREATE TABLE app_private.User (
  id          text PRIMARY KEY,
  password    text,
  created_by  text,
  updated_by  text,
  created_at  timestamp,
  updated_at  timestamp
);

CREATE TABLE app_private.Session (
  token           text PRIMARY KEY,
  user_id         text not null REFERENCES app_public.User,
  invalid_after   timestamp not null,
  data            jsonb
);
CREATE INDEX IF NOT EXISTS "session_expiration_index" ON app_private.Session(invalid_after);
CREATE INDEX IF NOT EXISTS "session_user_index" ON app_private.Session(user_id);

CREATE OR REPLACE VIEW app_private.Active_Sessions AS
  SELECT * FROM app_private.Session S
  WHERE S.invalid_after > NOW();