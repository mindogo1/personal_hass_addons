# -------- Builder: fetch source + build (dev deps available) --------
FROM node:22-alpine AS build
WORKDIR /src

# Needed for native modules / CLIs
RUN apk add --no-cache git python3 make g++

# Clone upstream (default branch). If you later want to pin a tag:
# RUN git clone --depth=1 -b v0.3.0 https://github.com/javedh-dev/tracktor .
RUN git clone --depth=1 https://github.com/javedh-dev/tracktor .

# Install with dev deps and build workspaces
RUN corepack enable && npm ci
RUN npm run build || true

# -------- Runtime: small image with only what we need --------
FROM node:22-alpine
WORKDIR /opt/tracktor

# sqlite CLI helps with fallback schema & debugging
RUN apk add --no-cache sqlite

# Copy built repo
COPY --from=build /src /opt/tracktor

# HA wrapper
COPY run.sh /run.sh
RUN sed -i 's/\r$//' /run.sh && chmod 0755 /run.sh

# Defaults (HA will override via /data/options.json)
ENV NODE_ENV=production \
    TZ=UTC \
    HOST=0.0.0.0 \
    PORT=3000

EXPOSE 3000

# Always go through our wrapper (handles DB & migrations)
ENTRYPOINT ["/bin/sh", "/run.sh"]
