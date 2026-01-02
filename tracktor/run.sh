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

# Install pnpm
RUN npm install -g pnpm

# Clone Tracktor
RUN git clone https://github.com/javedh-dev/tracktor.git .

# Install + build (DO NOT PRUNE)
RUN pnpm install --frozen-lockfile \
 && pnpm build

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
