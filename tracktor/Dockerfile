ARG BUILD_FROM=ghcr.io/hassio-addons/base:14.0.2
FROM ${BUILD_FROM}

ENV NODE_ENV=production

WORKDIR /opt/tracktor

# System dependencies
RUN apk add --no-cache \
    nodejs \
    git \
    python3 \
    make \
    g++ \
 && npm install -g pnpm

# Clone upstream
RUN git clone https://github.com/javedh-dev/tracktor.git .

# Install deps + build ONCE
RUN pnpm install --frozen-lockfile \
 && pnpm build \
 && pnpm prune --prod

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]