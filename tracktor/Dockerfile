# syntax=docker/dockerfile:1

############################
# Build Stage
############################
FROM node:22-alpine AS build

ARG GIT_REF=dev
ENV NODE_ENV=production

# deps for native modules (sqlite3) during build
RUN apk add --no-cache git python3 make g++

WORKDIR /src

# clone upstream source
RUN git clone --depth=1 -b "${GIT_REF}" https://github.com/javedh-dev/tracktor .

# install dependencies & build
# prefer npm (package-lock.json exists)
RUN --mount=type=cache,target=/root/.npm \
    npm ci && npm run build

############################
# Runtime Stage
############################
FROM node:22-alpine

ENV NODE_ENV=production
WORKDIR /opt/tracktor

# copy the built app and package metadata
COPY --from=build /src .

# install prod-only deps
RUN --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev

# add HA wrapper
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 3000
ENTRYPOINT ["/bin/sh","/run.sh"]
