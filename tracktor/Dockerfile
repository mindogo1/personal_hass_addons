ARG BUILD_FROM=ghcr.io/hassio-addons/base:14.0.2
FROM ${BUILD_FROM}

ENV NODE_ENV=production

WORKDIR /opt/tracktor

# ---- system dependencies (BUILD TIME ONLY)
RUN apk add --no-cache \
    nodejs \
    npm \
    git \
    python3 \
    make \
    g++

# ---- install pnpm for BUILD ONLY
RUN npm install -g pnpm

# ---- clone Tracktor (pinned by updater)
RUN git clone https://github.com/javedh-dev/tracktor.git .

# ---- install deps + build + prune
RUN pnpm install --frozen-lockfile \
 && pnpm build \
 && pnpm prune --prod \
 && npm uninstall -g pnpm

# ---- runtime script
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
