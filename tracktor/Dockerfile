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

WORKDIR /opt/tracktor
RUN rm -rf /opt/tracktor/* /opt/tracktor/.[!.]* /opt/tracktor/..?* \
 && git clone --depth=1 https://github.com/javedh-dev/tracktor .

WORKDIR /opt/tracktor

# ---- install deps (pnpm) ----
RUN pnpm install --frozen-lockfile --prod

# ---- runtime ----
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
