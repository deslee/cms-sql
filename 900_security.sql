-- USERS
ALTER TABLE app_public.Users ENABLE ROW LEVEL SECURITY;
GRANT SELECT, UPDATE ON TABLE app_public.Users to cms_app_user;
CREATE POLICY select_user ON app_public.Users FOR SELECT USING (id=current_setting('jwt.claims.userId', true)::text);
CREATE POLICY update_user ON app_public.Users FOR UPDATE USING (id=current_setting('jwt.claims.userId', true)::text);

-- ZONES
ALTER TABLE app_public.Zones ENABLE ROW LEVEL SECURITY;
GRANT SELECT, UPDATE ON TABLE app_public.Zones to cms_app_user;
CREATE POLICY zones ON app_public.Zones FOR ALL
  USING((SELECT count(*) FROM app_public.zoneusers zu WHERE zu.zone_id=id AND zu.user_id=current_setting('jwt.claims.userId', true)::text) > 0)
  WITH CHECK((SELECT count(*) FROM app_public.zoneusers zu WHERE zu.zone_id=id AND zu.user_id=current_setting('jwt.claims.userId', true)::text) > 0);

GRANT SELECT, UPDATE ON TABLE app_public.ZoneUsers to cms_app_user;
ALTER TABLE app_public.ZoneUsers ENABLE ROW LEVEL SECURITY;
CREATE POLICY zoneusers ON app_public.ZoneUsers FOR ALL
  USING(user_id=current_setting('jwt.claims.userId', true)::text)
  WITH CHECK(user_id=current_setting('jwt.claims.userId', true)::text);

-- ITEMS
ALTER TABLE app_public.Items ENABLE ROW LEVEL SECURITY;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE app_public.Items to cms_app_user;
CREATE POLICY items ON app_public.Items FOR ALL
  USING((SELECT count(*) FROM app_public.zoneusers zu WHERE zu.zone_id=app_public.Items.zone_id AND zu.user_id=current_setting('jwt.claims.userId', true)::text) > 0);

-- GROUPS
ALTER TABLE app_public.Groups ENABLE ROW LEVEL SECURITY;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE app_public.Groups to cms_app_user;
CREATE POLICY groups ON app_public.Groups FOR ALL
  USING((SELECT count(*) FROM app_public.zoneusers zu WHERE zu.zone_id=app_public.Groups.zone_id AND zu.user_id=current_setting('jwt.claims.userId', true)::text) > 0);

-- ASSETS
ALTER TABLE app_public.Assets ENABLE ROW LEVEL SECURITY;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE app_public.Assets to cms_app_user;
CREATE POLICY assets ON app_public.Assets FOR ALL
  USING((SELECT count(*) FROM app_public.zoneusers zu WHERE zu.zone_id=app_public.Assets.zone_id AND zu.user_id=current_setting('jwt.claims.userId', true)::text) > 0);

-- ITEM GROUPS
ALTER TABLE app_public.itemgroups ENABLE ROW LEVEL SECURITY;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE app_public.itemgroups to cms_app_user;
CREATE POLICY itemgroups ON app_public.itemgroups FOR ALL
  USING((SELECT count(*) FROM app_public.zoneusers zu WHERE zu.zone_id=app_public.itemgroups.zone_id AND zu.user_id=current_setting('jwt.claims.userId', true)::text) > 0);

-- ITEM ASSETS
ALTER TABLE app_public.itemassets ENABLE ROW LEVEL SECURITY;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE app_public.itemassets to cms_app_user;
CREATE POLICY itemassets ON app_public.itemassets FOR ALL
  USING((SELECT count(*) FROM app_public.zoneusers zu WHERE zu.zone_id=app_public.itemassets.zone_id AND zu.user_id=current_setting('jwt.claims.userId', true)::text) > 0);

