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

CREATE TABLE app_public.ItemGroups (
  item_id     text,
  group_id    text,
  zone_id     text,
  created_by  text,
  updated_by  text,
  item_order  integer,
  group_order integer,
  created_at  timestamp,
  updated_at  timestamp,
  FOREIGN KEY (item_id, zone_id) REFERENCES app_public.items(id, zone_id),
  FOREIGN KEY (group_id, zone_id) REFERENCES app_public.groups(id, zone_id),
  PRIMARY KEY (item_id, group_id, zone_id)
);

CREATE TABLE app_public.ItemAssets (
  item_id     text,
  asset_id    text,
  zone_id     text,
  created_by  text,
  updated_by  text,
  item_order  integer,
  asset_order integer,
  created_at  timestamp,
  updated_at  timestamp,
  FOREIGN KEY (item_id, zone_id) REFERENCES app_public.items(id, zone_id),
  FOREIGN KEY (asset_id, zone_id) REFERENCES app_public.assets(id, zone_id),
  PRIMARY KEY (item_id, asset_id, zone_id)
);