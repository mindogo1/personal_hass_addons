ARG BUILD_FROM=node:22-alpine

############################
# Build stage
############################
FROM ${BUILD_FROM} AS build

WORKDIR /opt/tracktor

# Required build deps
RUN apk add --no-cache git python3 make g++

# Tracktor version (bump this when updating)
ARG TRACKTOR_VERSION=1.0.2

# Clean clone (important for HA rebuilds)
RUN rm -rf /opt/tracktor/* /opt/tracktor/.[!.]* /opt/tracktor/..?* \
 && git clone --depth=1 --branch v${TRACKTOR_VERSION} https://github.com/javedh-dev/tracktor .

# Enable pnpm
RUN corepack enable \
 && corepack prepare pnpm@latest --activate

# Install deps & build
RUN pnpm install --frozen-lockfile \
 && pnpm build


############################
# Runtime stage
############################
FROM node:22-alpine

WORKDIR /opt/tracktor

# Runtime deps only
RUN apk add --no-cache sqlite tzdata

# Copy built app
COPY --from=build /opt/tracktor /opt/tracktor

# Home Assistant data dir
VOLUME ["/data"]

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

CMD ["/run.sh"]
