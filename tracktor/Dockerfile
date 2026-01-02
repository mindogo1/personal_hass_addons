ARG BUILD_FROM=ghcr.io/hassio-addons/base:14.0.2
FROM ${BUILD_FROM}

ENV NODE_ENV=production

WORKDIR /opt/tracktor

# ---- build deps only
RUN apk add --no-cache \
    nodejs \
    npm \
    git \
    python3 \
    make \
    g++

# pnpm is REQUIRED by Tracktor, but only for build
RUN npm install -g pnpm

# Clone Tracktor (tag is pinned by your updater workflow)
RUN git clone https://github.com/javedh-dev/tracktor.git .

# Build Tracktor
RUN pnpm install --frozen-lockfile \
 && pnpm build \
 && pnpm prune --prod

# Runtime entry
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
