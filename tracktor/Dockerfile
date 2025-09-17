# syntax=docker/dockerfile:1

############################
# Build Stage
############################
FROM node:22-alpine AS build

ARG GIT_REF=dev

# Tools for native builds (e.g., sqlite3 bindings) during install
RUN apk add --no-cache git python3 make g++

WORKDIR /src

# Clone upstream source
RUN git clone --depth=1 -b "${GIT_REF}" https://github.com/javedh-dev/tracktor .

# Install ALL deps incl. dev so TypeScript (tsc) exists, then build
RUN --mount=type=cache,target=/root/.npm \
    npm ci && npm run build

# Prune dev deps but keep compiled native modules
RUN npm prune --omit=dev

############################
# Runtime Stage
############################
FROM node:22-alpine

ENV NODE_ENV=production
WORKDIR /opt/tracktor

# Copy built app and pruned node_modules from build stage
COPY --from=build /src ./

# Add HA wrapper
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 3000
ENTRYPOINT ["/bin/sh","/run.sh"]
