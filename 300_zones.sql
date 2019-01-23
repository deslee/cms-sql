CREATE TABLE app_public.Zones (
  id          text PRIMARY KEY,
  name        text NOT NULL,
  data        jsonb,
  created_by  text,
  updated_by  text,
  created_at  timestamp,
  updated_at  timestamp,
  UNIQUE (name)
);

COMMENT ON TABLE app_public.Zones is E'@omit create';