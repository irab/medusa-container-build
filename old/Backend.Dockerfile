## TODO - slim down image

FROM node:alpine3.18 AS builder

WORKDIR /app

RUN apk update && \
  apk add nodejs yarn

COPY ./medusa . 

RUN rm -rf node_modules

RUN yarn add medusa-plugin-file-cloud-storage medusa-plugin-sendgrid medusa-payment-stripe medusa-file-minio

RUN yarn global add @medusajs/medusa-cli@1.3.22

RUN yarn install

COPY ./seed.json seed.json

COPY ./medusa-config-backend.js medusa-config.js

COPY ./medusa.sh .

RUN yarn run build:server

EXPOSE 9000

CMD ["./medusa.sh", "start"]