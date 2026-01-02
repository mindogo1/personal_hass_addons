ARG BUILD_FROM=ghcr.io/hassio-addons/base:14.0.2
FROM ${BUILD_FROM}

ENV NODE_ENV=production

WORKDIR /opt/tracktor

# System dependencies
RUN apk add --no-cache \
    nodejs \
    npm \
    git \
    python3 \
    make \
    g++

# pnpm (build-time only)
RUN npm install -g pnpm

# Clone Tracktor (tag pinned by your updater)
RUN git clone https://github.com/javedh-dev/tracktor.git .

# Install deps and build ONCE
RUN pnpm install --frozen-lockfile \
 && pnpm build \
 && pnpm prune --prod \
 && npm uninstall -g pnpm

# Runtime script
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
