FROM node:lts

WORKDIR /app/admin

ENV NODE_OPTIONS=--openssl-legacy-provider

COPY ./medusa .

RUN rm -rf node_modules

RUN apt update

RUN apt -y install yarn

RUN yarn add crossenv

RUN yarn build

COPY medusa-config-admin.js medusa-config.js

EXPOSE 7001

CMD ["yarn", "start"]