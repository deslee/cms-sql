
CREATE TABLE app_public.Items (
  id          text,
  zone_id     text REFERENCES app_public.Zones NOT NULL,
  name        text,
  password    text,
  type        text,
  created_by  text,
  updated_by  text,
  created_at  timestamp,
  updated_at  timestamp,
  PRIMARY KEY (id, zone_id),
  UNIQUE (zone_id, name)
);
ALTER TABLE app_public.Items ENABLE ROW LEVEL SECURITY;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE app_public.Items to cms_app_user;
CREATE POLICY items ON app_public.Items FOR ALL
  USING((SELECT count(*) FROM app_public.zoneusers zu WHERE zu.zone_id=zone_id AND zu.user_id=current_setting('jwt.claims.userId', true)::text) > 0)
  WITH CHECK((SELECT count(*) FROM app_public.zoneusers zu WHERE zu.zone_id=zone_id AND zu.user_id=current_setting('jwt.claims.userId', true)::text) > 0)