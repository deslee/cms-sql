CREATE OR REPLACE FUNCTION app_public.createZone(zone app_public.Zones) returns app_public.Zones AS $$
  declare ZResult app_public.zones;

  BEGIN
    INSERT INTO app_public.zones (SELECT (zone).*) RETURNING * into ZResult;
    INSERT INTO app_public.zoneusers (zone_id, user_id) VALUES (ZResult.id, current_setting('jwt.claims.userId', true)::text);
    RETURN ZResult;
  end;
$$ language plpgsql STRICT SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION app_public.createZone(app_public.Zones) TO cms_app_user;