CREATE TABLE app_public.Group (
  id          text,
  zone_id     text REFERENCES app_public.Zone NOT NULL,
  name        text NOT NULL,
  data        jsonb,
  created_by  text,
  updated_by  text,
  created_at  timestamp,
  updated_at  timestamp,
  PRIMARY KEY (id, zone_id),
  UNIQUE (zone_id, name)
);

CREATE INDEX IF NOT EXISTS "groups_zoneid_index" ON app_public.Group(zone_id);