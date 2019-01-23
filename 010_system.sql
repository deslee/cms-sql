-- $ npx postgraphile -c postgres://cms_graphql:password@fin/cms --schema app_public --watch --token app_public.jwt_token --secret asdf --default-role cms_app_user_anonymous

CREATE USER cms_graphql PASSWORD 'password';

CREATE SCHEMA app_public;
CREATE SCHEMA app_hidden;
CREATE SCHEMA app_private;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";


CREATE ROLE cms_app_user;
CREATE ROLE cms_app_user_anonymous;

-- anyone query public schema
GRANT cms_app_user_anonymous TO cms_graphql;
GRANT cms_app_user TO cms_graphql;
GRANT USAGE ON SCHEMA app_public TO cms_app_user, cms_app_user_anonymous;
-- REVOKE USAGE ON SCHEMA app_public FROM graphql;

-- anyone can register