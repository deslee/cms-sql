-- thanks to https://github.com/graphile/postgraphile/blob/master/examples/forum/TUTORIAL.md#registering-users
CREATE OR REPLACE FUNCTION app_public.register(email text, password text, data JSON) returns app_public.users AS $$
  DECLARE publicUser app_public.users;
  DECLARE privateUser app_private.users;

  BEGIN
    IF length(password) < 8 THEN
      RAISE EXCEPTION 'password too short';
    END IF;

    INSERT INTO app_private.users (id, password) VALUES
    (uuid_generate_v4(), crypt(password, gen_salt('bf')))
    RETURNING * into privateUser;

    INSERT INTO app_public.users (id, email, data) VALUES (privateUser.id, email, data)
    RETURNING * into publicUser;

    RETURN publicUser;
  end;
$$ language plpgsql STRICT SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION app_public.register(text, text, json) TO cms_app_user_anonymous;

CREATE OR REPLACE FUNCTION app_public.update_password(user_id text, newPassword text) returns app_public.users AS $$
  DECLARE publicUser app_public.users;

  BEGIN
    IF length(newPassword) < 8 THEN
      RAISE EXCEPTION 'password too short';
    END IF;

    UPDATE app_private.users SET password=crypt(newPassword, gen_salt('bf')) WHERE id=user_id;

    SELECT * into publicUser FROM app_public.users WHERE id=user_id;

    return publicUser;
  end;
$$ language plpgsql STRICT SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION app_public.update_password(text, text) TO cms_app_user;

CREATE TYPE app_public.jwt_token as (
  role text,
  userId text
);

CREATE OR REPLACE FUNCTION app_public.authenticate(
  email text,
  password text
) returns app_public.jwt_token as $$
  declare userPrivate app_private.users;

  BEGIN
    SELECT PRIVATE.* INTO userPrivate
    FROM app_private.users as PRIVATE
    INNER JOIN app_public.users "PUBLIC"
    ON PRIVATE.id = "PUBLIC".id
    WHERE "PUBLIC".email=authenticate.email;

  IF userPrivate.password = crypt(authenticate.password, userPrivate.password) THEN
    return ('cms_app_user', userPrivate.id)::app_public.jwt_token;
  ELSE
    return null;
  end if;
  end;
$$ LANGUAGE plpgsql STRICT SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION app_public.authenticate(text, text) TO cms_app_user_anonymous;

CREATE OR REPLACE FUNCTION app_public.me() RETURNS app_public.users as $$
  SELECT * FROM app_public.users
  WHERE id = current_setting('jwt.claims.userId', true)::text
$$ language sql stable;