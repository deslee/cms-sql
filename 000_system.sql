CREATE USER graphql PASSWORD 'password';


CREATE SCHEMA app_public;
CREATE SCHEMA app_hidden;
CREATE SCHEMA app_private;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE ROLE app_user;
CREATE ROLE app_user_anonymous;

-- anyone query public schema
GRANT app_user_anonymous TO graphql;
GRANT app_user TO graphql;
GRANT USAGE ON SCHEMA app_public TO app_user, app_user_anonymous;
-- REVOKE USAGE ON SCHEMA app_public FROM graphql;

-- anyone can register