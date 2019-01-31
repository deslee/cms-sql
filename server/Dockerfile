FROM node:11 AS cms-http-builder
WORKDIR /src
COPY ./package*.json ./
RUN npm install
COPY ./ ./

FROM node:11 AS cms-http
WORKDIR /app
EXPOSE 80
ENV PORT=80
COPY --from=cms-http-builder /src /app
CMD ["node", "server.js"]