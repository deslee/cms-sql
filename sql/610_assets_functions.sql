CREATE OR REPLACE FUNCTION app_public.Asset_extension(asset app_public.asset) RETURNS text as $$
  SELECT asset.data->>'extension'
$$ language sql STABLE;

CREATE OR REPLACE FUNCTION app_public.Asset_file_name(asset app_public.asset) RETURNS text as $$
    SELECT asset.data->>'originalFilename'
$$ language sql STABLE;

CREATE OR REPLACE FUNCTION app_public.Asset_key(asset app_public.asset) RETURNS text as $$
    SELECT asset.data->>'key'
$$ language sql STABLE;