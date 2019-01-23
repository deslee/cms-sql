/* We wanna store the password in a private schema, because Postgraphile likes to use full table selects */
CREATE TABLE app_private.Users (
  id          text PRIMARY KEY,
  password    text,
  created_by  text,
  updated_by  text,
  created_at  timestamp,
  updated_at  timestamp
);

CREATE TABLE app_public.Users (
  id          text PRIMARY KEY REFERENCES app_private.Users,
  email       text NOT NULL,
  data        jsonb,
  created_by  text,
  updated_by  text,
  created_at  timestamp,
  updated_at  timestamp,
  UNIQUE (email)
);