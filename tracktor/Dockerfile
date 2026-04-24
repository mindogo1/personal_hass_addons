# ---------- BUILD STAGE ----------
FROM node:20-alpine AS builder

WORKDIR /app

# Build deps
RUN apk add --no-cache git python3 make g++

# Use pnpm (Tracktor uses it)
RUN npm install -g pnpm

# Get source
RUN git clone https://github.com/javedh-dev/tracktor.git .

# Install + build
RUN pnpm install --no-frozen-lockfile \
 && pnpm build \
 && pnpm prune --prod

# ---------- RUNTIME STAGE ----------
FROM ghcr.io/hassio-addons/base:14.0.2

ENV NODE_ENV=production

WORKDIR /opt/tracktor

# Only runtime deps
RUN apk add --no-cache nodejs

# Copy built app
COPY --from=builder /app /opt/tracktor

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]