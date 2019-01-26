-- USERS
ALTER TABLE app_public.User ENABLE ROW LEVEL SECURITY;
GRANT SELECT, UPDATE ON TABLE app_public.User to cms_app_user;
CREATE POLICY select_user ON app_public.User FOR SELECT USING (id=current_setting('claims.userId', true)::text);
CREATE POLICY update_user ON app_public.User FOR UPDATE USING (id=current_setting('claims.userId', true)::text);

-- ZONES
ALTER TABLE app_public.Zone ENABLE ROW LEVEL SECURITY;
GRANT SELECT, UPDATE ON TABLE app_public.Zone to cms_app_user;
CREATE POLICY zones ON app_public.Zone FOR ALL
  USING((SELECT count(*) FROM app_public.ZoneUser zu WHERE zu.zone_id=id AND zu.user_id=current_setting('claims.userId', true)::text) > 0)
  WITH CHECK((SELECT count(*) FROM app_public.ZoneUser zu WHERE zu.zone_id=id AND zu.user_id=current_setting('claims.userId', true)::text) > 0);

GRANT SELECT, UPDATE ON TABLE app_public.ZoneUser to cms_app_user;
ALTER TABLE app_public.ZoneUser ENABLE ROW LEVEL SECURITY;
CREATE POLICY zoneusers ON app_public.ZoneUser FOR ALL
  USING(user_id=current_setting('claims.userId', true)::text)
  WITH CHECK(user_id=current_setting('claims.userId', true)::text);

-- ITEMS
ALTER TABLE app_public.Item ENABLE ROW LEVEL SECURITY;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE app_public.Item to cms_app_user;
CREATE POLICY items ON app_public.Item FOR ALL
  USING((SELECT count(*) FROM app_public.ZoneUser zu WHERE zu.zone_id=app_public.Item.zone_id AND zu.user_id=current_setting('claims.userId', true)::text) > 0);

-- GROUPS
ALTER TABLE app_public.Group ENABLE ROW LEVEL SECURITY;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE app_public.Group to cms_app_user;
CREATE POLICY groups ON app_public.Group FOR ALL
  USING((SELECT count(*) FROM app_public.ZoneUser zu WHERE zu.zone_id=app_public.Group.zone_id AND zu.user_id=current_setting('claims.userId', true)::text) > 0);

-- ASSETS
ALTER TABLE app_public.Asset ENABLE ROW LEVEL SECURITY;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE app_public.Asset to cms_app_user;
CREATE POLICY assets ON app_public.Asset FOR ALL
  USING((SELECT count(*) FROM app_public.ZoneUser zu WHERE zu.zone_id=app_public.Asset.zone_id AND zu.user_id=current_setting('claims.userId', true)::text) > 0);

-- ITEM GROUPS
ALTER TABLE app_public.ItemGroup ENABLE ROW LEVEL SECURITY;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE app_public.ItemGroup to cms_app_user;
CREATE POLICY itemgroups ON app_public.ItemGroup FOR ALL
  USING((SELECT count(*) FROM app_public.ZoneUser zu WHERE zu.zone_id=app_public.ItemGroup.zone_id AND zu.user_id=current_setting('claims.userId', true)::text) > 0);

-- ITEM ASSETS
ALTER TABLE app_public.ItemAsset ENABLE ROW LEVEL SECURITY;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE app_public.ItemAsset to cms_app_user;
CREATE POLICY itemassets ON app_public.ItemAsset FOR ALL
  USING((SELECT count(*) FROM app_public.ZoneUser zu WHERE zu.zone_id=app_public.ItemAsset.zone_id AND zu.user_id=current_setting('claims.userId', true)::text) > 0);


-- admin user config
GRANT ALL ON ALL TABLES IN SCHEMA app_public, app_private, app_hidden TO cms_admin_user;