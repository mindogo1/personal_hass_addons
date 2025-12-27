ARG BUILD_FROM=ghcr.io/hassio-addons/base:14.0.2
FROM ${BUILD_FROM}

ENV NODE_ENV=production

WORKDIR /opt/tracktor

# System deps
RUN apk add --no-cache \
    nodejs \
    npm \
    git \
    python3 \
    make \
    g++

# Install pnpm the safe way (Alpine-compatible)
RUN npm install -g pnpm

# Clone Tracktor (ALWAYS WORKS)
RUN git clone https://github.com/javedh-dev/tracktor.git .

# Install + build
RUN pnpm install --frozen-lockfile \
 && pnpm build \
 && pnpm prune --prod

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
