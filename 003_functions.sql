-- thanks to https://github.com/graphile/postgraphile/blob/master/examples/forum/TUTORIAL.md#registering-users
CREATE FUNCTION app_public.register(email text, password text, data JSON) returns app_public.users AS $$
  DECLARE publicUser app_public.users;
  DECLARE privateUser app_private.users;

  BEGIN
    INSERT INTO app_private.users (id, password) VALUES
    (uuid_generate_v4(), crypt(password, gen_salt('bf')))
    RETURNING * into privateUser;

    INSERT INTO app_public.users (id, email, data) VALUES (privateUser.id, email, data)
    RETURNING * into publicUser;

    RETURN publicUser;
  end;
$$ language plpgsql STRICT SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION app_public.register(text, text, json) TO app_user_anonymous;

CREATE TYPE app_public.jwt_token as (
  role text,
  userId text
);

CREATE FUNCTION app_public.authenticate(
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
    return ('app_user', userPrivate.id)::app_public.jwt_token;
  ELSE
    return null;
  end if;
  end;
$$ LANGUAGE plpgsql STRICT SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION app_public.authenticate(text, text) TO app_user_anonymous;

CREATE FUNCTION app_public.me() RETURNS app_public.users as $$
  SELECT * FROM app_public.users
  WHERE id = current_setting('jwt.claims.userId', true)::text
$$ language sql stable;

