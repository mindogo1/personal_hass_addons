# ---------- Builder: fetch source and build ----------
FROM node:22-alpine AS build
WORKDIR /src

# native build tooling
RUN apk add --no-cache git python3 make g++

# pin to a release tag for reproducibility; the updater workflow rewrites this line
# to the latest release (e.g. v0.3.1). If you want HEAD instead, drop "-b v0.3.1".
RUN git clone --depth=1 -b v0.3.1 https://github.com/javedh-dev/tracktor .

# install deps (including devDeps for build) and build
RUN corepack enable && npm ci
RUN npm run build || true

# ---------- Runtime: slim Node + sqlite CLI ----------
FROM node:22-alpine
WORKDIR /opt/tracktor

# sqlite CLI helps with first-run DB init and debug
RUN apk add --no-cache sqlite

# copy built app
COPY --from=build /src /opt/tracktor

# our HA wrapper (handles DB path + PIN seeding + start)
COPY run.sh /run.sh
RUN sed -i 's/\r$//' /run.sh && chmod 0755 /run.sh

ENV NODE_ENV=production \
    HOST=0.0.0.0 \
    PORT=3000

EXPOSE 3000
ENTRYPOINT ["/bin/sh", "/run.sh"]
