ARG BUILD_FROM
FROM ${BUILD_FROM}

# ---- base deps ----
RUN apk add --no-cache \
  nodejs \
  npm \
  git \
  bash \
  sqlite \
  ca-certificates \
  curl

# ---- install pnpm ----
RUN npm install -g pnpm

# ---- fetch Tracktor (idempotent for HA rebuilds) ----
WORKDIR /opt
RUN rm -rf tracktor \
 && git clone --depth=1 https://github.com/javedh-dev/tracktor tracktor

WORKDIR /opt/tracktor

# ---- install deps (pnpm) ----
RUN pnpm install --frozen-lockfile --prod

# ---- runtime ----
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
