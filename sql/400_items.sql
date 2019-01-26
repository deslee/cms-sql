CREATE TABLE app_public.Item (
  id          text,
  zone_id     text REFERENCES app_public.Zone NOT NULL,
  name        text NOT NULL,
  password    text,
  data        jsonb,
  date        timestamp with time zone,
  type        text,
  created_by  text,
  updated_by  text,
  created_at  timestamp,
  updated_at  timestamp,
  PRIMARY KEY (id, zone_id),
  UNIQUE (zone_id, name)
);

CREATE INDEX IF NOT EXISTS "items_zoneid_index" ON app_public.Item(zone_id);
CREATE INDEX IF NOT EXISTS "items_date_index" ON app_public.Item(date);
CREATE INDEX IF NOT EXISTS "items_type_index" ON app_public.Item(type);