CREATE TABLE app_public.Zone_User (
  zone_id     text REFERENCES app_public.Zone,
  user_id     text REFERENCES app_public.User,
  created_by  text,
  updated_by  text,
  user_order  integer,
  zone_order  integer,
  created_at  timestamp,
  updated_at  timestamp,
  PRIMARY KEY (zone_id, user_id)
);
CREATE INDEX IF NOT EXISTS "zoneusers_zoneid_index" ON app_public.Zone_User(zone_id);
CREATE INDEX IF NOT EXISTS "zoneusers_userid_index" ON app_public.Zone_User(user_id);

CREATE TABLE app_public.Item_Group (
  item_id     text,
  group_id    text,
  zone_id     text,
  created_by  text,
  updated_by  text,
  item_order  integer,
  group_order integer,
  created_at  timestamp,
  updated_at  timestamp,
  FOREIGN KEY (item_id, zone_id) REFERENCES app_public.Item(id, zone_id),
  FOREIGN KEY (group_id, zone_id) REFERENCES app_public.Group(id, zone_id),
  PRIMARY KEY (item_id, group_id, zone_id)
);
CREATE INDEX IF NOT EXISTS "itemgroups_zoneid_index" ON app_public.Item_Group(zone_id);
CREATE INDEX IF NOT EXISTS "itemgroups_itemid_index" ON app_public.Item_Group(item_id);
CREATE INDEX IF NOT EXISTS "itemgroups_groupid_index" ON app_public.Item_Group(group_id);

CREATE TABLE app_public.Item_Asset (
  item_id     text,
  asset_id    text,
  zone_id     text,
  created_by  text,
  updated_by  text,
  item_order  integer,
  asset_order integer,
  created_at  timestamp,
  updated_at  timestamp,
  FOREIGN KEY (item_id, zone_id) REFERENCES app_public.Item(id, zone_id),
  FOREIGN KEY (asset_id, zone_id) REFERENCES app_public.Asset(id, zone_id),
  PRIMARY KEY (item_id, asset_id, zone_id)
);
CREATE INDEX IF NOT EXISTS "itemassets_zoneid_index" ON app_public.Item_Asset(zone_id);
CREATE INDEX IF NOT EXISTS "itemassets_itemid_index" ON app_public.Item_Asset(item_id);
CREATE INDEX IF NOT EXISTS "itemassets_assetid_index" ON app_public.Item_Asset(asset_id);