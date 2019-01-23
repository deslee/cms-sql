
CREATE TABLE app_public.Groups (
  id          text,
  zone_id     text REFERENCES app_public.Zones NOT NULL,
  name        text,
  data        jsonb,
  created_by  text,
  updated_by  text,
  created_at  timestamp,
  updated_at  timestamp,
  PRIMARY KEY (id, zone_id),
  UNIQUE (zone_id, name)
);