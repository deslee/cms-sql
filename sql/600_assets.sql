CREATE TABLE app_public.Asset (
  id          text,
  zone_id     text REFERENCES app_public.Zone NOT NULL,
  state       text,
  type        text,
  data        jsonb,
  created_by  text,
  updated_by  text,
  created_at  timestamp,
  updated_at  timestamp,
  PRIMARY KEY (id, zone_id)
);

CREATE INDEX IF NOT EXISTS "assets_zoneid_index" ON app_public.Asset(zone_id);