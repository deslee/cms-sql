CREATE OR REPLACE FUNCTION app_public.trigger_set_audit_update_fields()
RETURNS TRIGGER AS $$
  BEGIN
    NEW.updated_at = now();
    NEW.updated_by = current_setting('jwt.claims.userId', true);
    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION app_public.trigger_set_audit_create_fields()
RETURNS TRIGGER AS $$
  BEGIN
    NEW.created_at = now();
    NEW.created_by = current_setting('jwt.claims.userId', true);
    NEW.updated_at = now();
    NEW.updated_by = current_setting('jwt.claims.userId', true);
    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

-- USERS
CREATE TRIGGER audit_fields_on_create BEFORE INSERT ON app_public.users
  FOR EACH ROW EXECUTE PROCEDURE app_public.trigger_set_audit_create_fields();

CREATE TRIGGER audit_fields_on_update BEFORE UPDATE ON app_public.users
  FOR EACH ROW EXECUTE PROCEDURE app_public.trigger_set_audit_update_fields();

-- ZONES
CREATE TRIGGER audit_fields_on_create BEFORE INSERT ON app_public.zones
  FOR EACH ROW EXECUTE PROCEDURE app_public.trigger_set_audit_create_fields();

CREATE TRIGGER audit_fields_on_update BEFORE UPDATE ON app_public.zones
  FOR EACH ROW EXECUTE PROCEDURE app_public.trigger_set_audit_update_fields();

-- ITEMS
CREATE TRIGGER audit_fields_on_create BEFORE INSERT ON app_public.items
  FOR EACH ROW EXECUTE PROCEDURE app_public.trigger_set_audit_create_fields();

CREATE TRIGGER audit_fields_on_update BEFORE UPDATE ON app_public.items
  FOR EACH ROW EXECUTE PROCEDURE app_public.trigger_set_audit_update_fields();

-- GROUPS
CREATE TRIGGER audit_fields_on_create BEFORE INSERT ON app_public.groups
  FOR EACH ROW EXECUTE PROCEDURE app_public.trigger_set_audit_create_fields();

CREATE TRIGGER audit_fields_on_update BEFORE UPDATE ON app_public.groups
  FOR EACH ROW EXECUTE PROCEDURE app_public.trigger_set_audit_update_fields();

-- ASSETS
CREATE TRIGGER audit_fields_on_create BEFORE INSERT ON app_public.assets
  FOR EACH ROW EXECUTE PROCEDURE app_public.trigger_set_audit_create_fields();

CREATE TRIGGER audit_fields_on_update BEFORE UPDATE ON app_public.assets
  FOR EACH ROW EXECUTE PROCEDURE app_public.trigger_set_audit_update_fields();

-- ZoneUsers
CREATE TRIGGER audit_fields_on_create BEFORE INSERT ON app_public.zoneusers
  FOR EACH ROW EXECUTE PROCEDURE app_public.trigger_set_audit_create_fields();

CREATE TRIGGER audit_fields_on_update BEFORE UPDATE ON app_public.zoneusers
  FOR EACH ROW EXECUTE PROCEDURE app_public.trigger_set_audit_update_fields();


-- ItemAssets
CREATE TRIGGER audit_fields_on_create BEFORE INSERT ON app_public.itemassets
  FOR EACH ROW EXECUTE PROCEDURE app_public.trigger_set_audit_create_fields();

CREATE TRIGGER audit_fields_on_update BEFORE UPDATE ON app_public.itemassets
  FOR EACH ROW EXECUTE PROCEDURE app_public.trigger_set_audit_update_fields();

-- ItemGroups
CREATE TRIGGER audit_fields_on_create BEFORE INSERT ON app_public.itemgroups
  FOR EACH ROW EXECUTE PROCEDURE app_public.trigger_set_audit_create_fields();

CREATE TRIGGER audit_fields_on_update BEFORE UPDATE ON app_public.itemgroups
  FOR EACH ROW EXECUTE PROCEDURE app_public.trigger_set_audit_update_fields();

