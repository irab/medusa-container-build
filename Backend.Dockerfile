FROM node:alpine3.18 as builder
WORKDIR /app

RUN apk update && \
  apk add nodejs yarn

COPY ./medusa . 

RUN rm -rf node_modules

RUN yarn install --loglevel=error

RUN yarn run build

## Runtime Image

FROM node:alpine3.18
WORKDIR /app

RUN apk update && \
  apk add nodejs yarn

RUN mkdir dist

COPY ./medusa.sh .

COPY ./medusa/package*.json .

RUN yarn global add @medusajs/medusa-cli@1.3.22

RUN yarn install --only=production

COPY --from=builder /app/dist ./dist

COPY ./seed.json seed.json

COPY ./medusa-config-backend.js medusa-config.js

EXPOSE 9000

CMD ["./medusa.sh", "start"]