ARG BUILD_FROM=ghcr.io/hassio-addons/base:14.0.2
FROM ${BUILD_FROM}

ARG TRACKTOR_VERSION=1.0.0

ENV PNPM_HOME=/opt/pnpm
ENV PATH=$PNPM_HOME:$PATH

WORKDIR /opt/tracktor

# Dependencies
RUN apk add --no-cache \
    nodejs \
    npm \
    git \
    python3 \
    make \
    g++

# Enable pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Clone Tracktor
RUN git clone --branch v${TRACKTOR_VERSION} --depth=1 \
    https://github.com/javedh-dev/tracktor.git .

# Install deps + BUILD
RUN pnpm install --frozen-lockfile \
 && pnpm build \
 && pnpm prune --prod

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
