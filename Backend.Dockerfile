## Build Image with outputs in /app/dist/

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

COPY ./medusa/medusa-config.js .

RUN yarn global add @medusajs/medusa-cli

RUN yarn install --only=production

COPY --from=builder /app/dist ./dist

EXPOSE 9000

CMD ["./medusa.sh", "start"]