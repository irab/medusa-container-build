FROM node:lts as builder

WORKDIR /app/admin

ENV NODE_OPTIONS=--openssl-legacy-provider

COPY ./medusa .

COPY medusa-config-admin.js medusa-config.js


RUN rm -rf node_modules

RUN apt update

RUN apt -y install yarn

RUN yarn add crossenv

RUN yarn build:admin

EXPOSE 7001

CMD ["yarn", "run", "start"]