docker run --rm --env CONNECTION_STRING="user=postgres password=password dbname=cms sslmode=disable host=postgres" --env ASSETS_DIR="./assets" --link postgres -v `pwd`/assets:/app/assets ff84d455fee6

docker run -it --rm --env DATABASE_URL=postgres://cms_graphql:password@postgres/cms --env DATABASE_SYSTEM_URL=postgres://cms_system:password@postgres/cms --env JWT_SECRET=abcdefg --link postgres -v `pwd`/assets:/app/assets -p 5000:80 08f27ce53f72