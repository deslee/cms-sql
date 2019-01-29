CREATE OR REPLACE FUNCTION app_public.create_zone(zone app_public.Zone) returns app_public.Zone AS $$
  declare ZResult app_public.Zone;

  BEGIN
    INSERT INTO app_public.Zone (SELECT (zone).*) RETURNING * into ZResult;
    INSERT INTO app_public.Zone_User (zone_id, user_id) VALUES (ZResult.id, current_setting('claims.userId', true)::text);
    RETURN ZResult;
  end;
$$ language plpgsql STRICT SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION app_public.create_zone(app_public.Zone) TO cms_app_user;