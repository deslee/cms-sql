-- $ npx postgraphile -c postgres://graphql:password@fin/cms --schema app_public --watch --token app_public.jwt_token --secret asdf

/* We wanna store the password in a private schema, because Postgraphile likes to use full table selects */
CREATE TABLE app_private.Users (
  id          text PRIMARY KEY,
  password    text,
  created_by  text,
  updated_by  text,
  created_at  timestamp,
  updated_at  timestamp
);

CREATE TABLE app_public.Users (
  id          text PRIMARY KEY REFERENCES app_private.Users,
  email       text NOT NULL,
  data        jsonb,
  created_by  text,
  updated_by  text,
  created_at  timestamp,
  updated_at  timestamp,
  UNIQUE (email)
);
ALTER TABLE app_public.Users ENABLE ROW LEVEL SECURITY;
CREATE POLICY select_user ON app_public.Users FOR SELECT
  USING (id=current_setting('jwt.claims.userId', true)::text);
GRANT SELECT, UPDATE ON TABLE app_public.Users to app_user;
-- DROP POLICY select_user ON app_public.Users;

comment on column app_public.Users.created_by is E'@omit create,update';
comment on column app_public.Users.updated_by is E'@omit create,update';
comment on column app_public.Users.created_at is E'@omit create,update';
comment on column app_public.Users.updated_at is E'@omit create,update';

CREATE TABLE app_public.Zones (
  id          text PRIMARY KEY,
  name        text,
  data        jsonb,
  created_by  text,
  updated_by  text,
  created_at  timestamp,
  updated_at  timestamp,
  UNIQUE (name)
);
comment on column app_public.Zones.created_by is E'@omit create,update';
comment on column app_public.Zones.updated_by is E'@omit create,update';
comment on column app_public.Zones.created_at is E'@omit create,update';
comment on column app_public.Zones.updated_at is E'@omit create,update';

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
comment on column app_public.ZoneUsers.created_by is E'@omit create,update';
comment on column app_public.ZoneUsers.updated_by is E'@omit create,update';
comment on column app_public.ZoneUsers.created_at is E'@omit create,update';
comment on column app_public.ZoneUsers.updated_at is E'@omit create,update';

CREATE TABLE app_public.Items (
  id          text PRIMARY KEY,
  zone_id     text REFERENCES app_public.Zones NOT NULL,
  name        text,
  password    text,
  type        text,
  created_by  text,
  updated_by  text,
  created_at  timestamp,
  updated_at  timestamp,
  UNIQUE (zone_id, name)
);
comment on column app_public.Items.created_by is E'@omit create,update';
comment on column app_public.Items.updated_by is E'@omit create,update';
comment on column app_public.Items.created_at is E'@omit create,update';
comment on column app_public.Items.updated_at is E'@omit create,update';

CREATE TABLE app_public.Groups (
  id          text PRIMARY KEY,
  zone_id     text REFERENCES app_public.Zones NOT NULL,
  name        text,
  data        jsonb,
  created_by  text,
  updated_by  text,
  created_at  timestamp,
  updated_at  timestamp,
  UNIQUE (zone_id, name)
);
comment on column app_public.Groups.created_by is E'@omit create,update';
comment on column app_public.Groups.updated_by is E'@omit create,update';
comment on column app_public.Groups.created_at is E'@omit create,update';
comment on column app_public.Groups.updated_at is E'@omit create,update';

CREATE TABLE app_public.ItemGroups (
  item_id     text REFERENCES app_public.Items,
  group_id    text REFERENCES app_public.Groups,
  created_by  text,
  updated_by  text,
  item_order  integer,
  group_order integer,
  created_at  timestamp,
  updated_at  timestamp,
  PRIMARY KEY (item_id, group_id)
);
comment on column app_public.ItemGroups.created_by is E'@omit create,update';
comment on column app_public.ItemGroups.updated_by is E'@omit create,update';
comment on column app_public.ItemGroups.created_at is E'@omit create,update';
comment on column app_public.ItemGroups.updated_at is E'@omit create,update';

CREATE TABLE app_public.Assets (
  id          text PRIMARY KEY,
  zone_id     text REFERENCES app_public.Zones NOT NULL,
  state       text,
  data        jsonb,
  created_by  text,
  updated_by  text,
  created_at  timestamp,
  updated_at  timestamp
);
comment on column app_public.Assets.created_by is E'@omit create,update';
comment on column app_public.Assets.updated_by is E'@omit create,update';
comment on column app_public.Assets.created_at is E'@omit create,update';
comment on column app_public.Assets.updated_at is E'@omit create,update';


CREATE TABLE app_public.ItemAssets (
  item_id     text REFERENCES app_public.Items,
  asset_id    text REFERENCES app_public.Assets,
  created_by  text,
  updated_by  text,
  item_order  integer,
  asset_order integer,
  created_at  timestamp,
  updated_at  timestamp,
  PRIMARY KEY (item_id, asset_id)
);
comment on column app_public.ItemAssets.created_by is E'@omit create,update';
comment on column app_public.ItemAssets.updated_by is E'@omit create,update';
comment on column app_public.ItemAssets.created_at is E'@omit create,update';
comment on column app_public.ItemAssets.updated_at is E'@omit create,update';