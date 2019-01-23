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

ALTER TABLE app_public.Zones ENABLE ROW LEVEL SECURITY;
GRANT SELECT, UPDATE ON TABLE app_public.Zones to cms_app_user;
CREATE POLICY zones ON app_public.Zones FOR ALL
  USING((SELECT count(*) FROM app_public.zoneusers zu WHERE zu.zone_id=id AND zu.user_id=current_setting('jwt.claims.userId', true)::text) > 0)
  WITH CHECK((SELECT count(*) FROM app_public.zoneusers zu WHERE zu.zone_id=id AND zu.user_id=current_setting('jwt.claims.userId', true)::text) > 0);

COMMENT ON TABLE app_public.Zones is E'@omit create';