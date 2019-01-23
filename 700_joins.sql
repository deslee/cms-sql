CREATE TABLE app_public.ZoneUsers (
  zone_id     text REFERENCES app_public.Zones,
  user_id     text REFERENCES app_public.Users,
  created_by  text,
  updated_by  text,
  user_order  integer,
  zone_order  integer,
  created_at  timestamp,
  updated_at  timestamp,
  PRIMARY KEY (zone_id, user_id)
);

GRANT SELECT, UPDATE ON TABLE app_public.ZoneUsers to cms_app_user;
ALTER TABLE app_public.ZoneUsers ENABLE ROW LEVEL SECURITY;
CREATE POLICY zoneusers ON app_public.ZoneUsers FOR ALL
  USING(user_id=current_setting('jwt.claims.userId', true)::text)
  WITH CHECK(user_id=current_setting('jwt.claims.userId', true)::text);

CREATE TABLE app_public.ItemGroups (
  item_id     text REFERENCES app_public.Items,
  group_id    text REFERENCES app_public.Groups,
  zone_id     text REFERENCES app_public.ZoneUsers,
  created_by  text,
  updated_by  text,
  item_order  integer,
  group_order integer,
  created_at  timestamp,
  updated_at  timestamp,
  PRIMARY KEY (item_id, group_id, zone_id)
);

CREATE TABLE app_public.ItemAssets (
  item_id     text REFERENCES app_public.Items,
  asset_id    text REFERENCES app_public.Assets,
  zone_id     text REFERENCES app_public.ZoneUsers,
  created_by  text,
  updated_by  text,
  item_order  integer,
  asset_order integer,
  created_at  timestamp,
  updated_at  timestamp,
  PRIMARY KEY (item_id, asset_id, zone_id)
);