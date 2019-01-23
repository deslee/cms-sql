
CREATE TABLE app_public.Items (
  id          text,
  zone_id     text REFERENCES app_public.Zones NOT NULL,
  name        text,
  password    text,
  data        jsonb,
  type        text,
  created_by  text,
  updated_by  text,
  created_at  timestamp,
  updated_at  timestamp,
  PRIMARY KEY (id, zone_id),
  UNIQUE (zone_id, name)
);