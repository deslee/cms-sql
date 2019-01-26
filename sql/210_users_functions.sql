-- given an email and a password, this function creates a user and hashes the password
-- thanks to https://github.com/graphile/postgraphile/blob/master/examples/forum/TUTORIAL.md#registering-users
CREATE OR REPLACE FUNCTION app_public.register(email text, password text, data JSON) returns app_public.User AS $$
  DECLARE publicUser app_public.User;
  DECLARE privateUser app_private.User;

  BEGIN
    IF length(password) < 8 THEN
      RAISE EXCEPTION 'password too short';
    END IF;

    INSERT INTO app_private.User (id, password) VALUES
    (uuid_generate_v4(), crypt(password, gen_salt('bf')))
    RETURNING * into privateUser;

    INSERT INTO app_public.User (id, email, data) VALUES (privateUser.id, email, data)
    RETURNING * into publicUser;

    RETURN publicUser;
  end;
$$ language plpgsql STRICT SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION app_public.register(text, text, json) TO cms_app_user_anonymous;

-- given correct permissions, update the users password
CREATE OR REPLACE FUNCTION app_public.update_password(user_id text, newPassword text) returns app_public.User AS $$
  DECLARE publicUser app_public.User;

  BEGIN
    IF user_id <> current_setting('claims.userId', false)::text THEN
      RAISE EXCEPTION 'unauthorized';
    end if;

    IF length(newPassword) < 8 THEN
      RAISE EXCEPTION 'password too short';
    END IF;

    UPDATE app_private.User SET password=crypt(newPassword, gen_salt('bf')) WHERE id=user_id;

    SELECT * into publicUser FROM app_public.User WHERE id=user_id;

    return publicUser;
  end;
$$ language plpgsql STRICT SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION app_public.update_password(text, text) TO cms_app_user;

-- authenticates the user, returning a session token if valid
CREATE OR REPLACE FUNCTION app_private.authenticate(
  email text,
  password text,
  sessionData    json
) returns app_private.Session as $$
  declare userPrivate app_private.User;
  declare "session" app_private.Session;
  declare expirationDate timestamp;

  BEGIN

    SELECT PRIVATE.* INTO userPrivate
    FROM app_private.User as PRIVATE
    INNER JOIN app_public.User "PUBLIC"
    ON PRIVATE.id = "PUBLIC".id
    WHERE "PUBLIC".email=authenticate.email
    AND PRIVATE.password=crypt(authenticate.password, PRIVATE.password);

  if userPrivate is null then
    return null;
  end if;

  expirationDate := (current_timestamp + INTERVAL '7' DAY);

  INSERT INTO app_private.Session(token, user_id, invalid_after, "data") VALUES
  (uuid_generate_v4(), userPrivate.id, expirationDate, sessionData) RETURNING * into "session";

  return "session";
  end;
$$ LANGUAGE plpgsql STRICT SECURITY INVOKER;

CREATE OR REPLACE FUNCTION app_private.clear_expired_sessions() RETURNS void as $$
  BEGIN
    DELETE FROM app_private.Session S WHERE S.invalid_after < NOW();
  end;
$$ LANGUAGE plpgsql STRICT SECURITY INVOKER;

CREATE OR REPLACE FUNCTION app_public.me() RETURNS app_public.User as $$
  SELECT * FROM app_public.User
  WHERE id = current_setting('claims.userId', true)::text
$$ language sql stable;