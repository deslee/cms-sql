CREATE TABLE app_public.Assets (
  id          text,
  zone_id     text REFERENCES app_public.Zones NOT NULL,
  state       text,
  data        jsonb,
  created_by  text,
  updated_by  text,
  created_at  timestamp,
  updated_at  timestamp,
  PRIMARY KEY (id, zone_id)
);

CREATE INDEX IF NOT EXISTS "assets_zoneid_index" ON app_public.Assets(zone_id);