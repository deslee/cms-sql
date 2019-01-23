CREATE TABLE app_public.Groups (
  id          text,
  zone_id     text REFERENCES app_public.Zones NOT NULL,
  name        text NOT NULL,
  data        jsonb,
  created_by  text,
  updated_by  text,
  created_at  timestamp,
  updated_at  timestamp,
  PRIMARY KEY (id, zone_id),
  UNIQUE (zone_id, name)
);

CREATE INDEX IF NOT EXISTS "groups_zoneid_index" ON app_public.Groups(zone_id);