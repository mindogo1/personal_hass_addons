# --- Builder stage: clone & build everything with devDependencies available ---
FROM node:22-alpine AS build
WORKDIR /src

# system deps sometimes used by node-gyp stacks
RUN apk add --no-cache git python3 make g++

# pull source (dev branch seems to be the default active branch upstream)
# you can switch to a tag if you want reproducibility, e.g.: -b v0.3.0
RUN git clone --depth=1 https://github.com/javedh-dev/tracktor . 

# install workspaces + devDeps and build both backend + frontend if present
# do NOT set NODE_ENV=production here; we need dev tools like tsc/tsx/drizzle-kit or sequelize-cli
RUN corepack enable && npm ci
RUN npm run build || true

# --- Runtime stage: small image with only built artifacts ---
FROM node:22-alpine
WORKDIR /opt/tracktor

# Copy the whole repository (built artifacts should be under /app/* or /dist/* depending on upstream)
COPY --from=build /src /opt/tracktor

# Create runtime dirs for HA persistence
RUN mkdir -p /data/tracktor /data/tracktor/uploads

# Copy our HA wrapper
COPY run.sh /run.sh
RUN sed -i 's/\r$//' /run.sh && chmod 0755 /run.sh

# Default env (HA options.json will override)
ENV NODE_ENV=production \
    TZ=UTC

# Expose the same port as in config.yaml
EXPOSE 5173

# Force our wrapper as the entrypoint so we can migrate/seed safely
ENTRYPOINT ["/bin/sh", "/run.sh"]
