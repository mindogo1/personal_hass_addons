# ---------- Builder: fetch source and build ----------
FROM node:22-alpine AS build
WORKDIR /src

# native build tooling
RUN apk add --no-cache git python3 make g++

# Clone default branch (currently 'dev'). To pin a commit, add a checkout step.
RUN git clone --depth=1 https://github.com/javedh-dev/tracktor .

# Install deps (including devDeps for build) and build
RUN corepack enable && npm ci
RUN npm run build || true

# ---------- Runtime: slim Node + sqlite CLI ----------
FROM node:22-alpine
WORKDIR /opt/tracktor

# sqlite CLI helps with first-run DB init and debugging
RUN apk add --no-cache sqlite

# Copy built app
COPY --from=build /src /opt/tracktor

# Preinstall runtime libs used by our PIN seeder (safe if already present)
RUN npm install --no-audit --no-fund --omit=dev bcryptjs @libsql/client || true

# Our HA wrapper (handles DB path + PIN seeding + start)
COPY run.sh /run.sh
RUN sed -i 's/\r$//' /run.sh && chmod 0755 /run.sh

ENV NODE_ENV=production \
    HOST=0.0.0.0 \
    PORT=3000

EXPOSE 3000
ENTRYPOINT ["/bin/sh", "/run.sh"]
