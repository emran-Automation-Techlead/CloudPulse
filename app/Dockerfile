# ---------------------------------------------------------------------------
# PLAIN ENGLISH: A Dockerfile is the recipe for packaging an application
# into a portable "container" that runs the same way everywhere. This
# recipe uses a "multi-stage build" — a build kitchen (stage 1) that has
# all the tools needed to prepare the app, and a much smaller, cleaner
# serving kitchen (stage 2) that only contains what's needed to actually
# run it. This keeps the final image small (faster deploys, smaller
# attack surface) and makes sure build tools never ship to production.
# The final image also deliberately runs as a non-root user, since a
# container running as root is one exploit away from root on the host.
# ---------------------------------------------------------------------------

# ---- Stage 1: build ----
FROM node:20-alpine AS build

WORKDIR /app

COPY package.json ./
RUN npm install --omit=dev

COPY src ./src

# ---- Stage 2: minimal runtime image ----
FROM node:20-alpine AS runtime

# Plain English: create a dedicated low-privilege user/group instead of
# running the app as root inside the container.
RUN addgroup -S cloudpulse && adduser -S cloudpulse -G cloudpulse

WORKDIR /app

COPY --from=build --chown=cloudpulse:cloudpulse /app/node_modules ./node_modules
COPY --from=build --chown=cloudpulse:cloudpulse /app/src ./src
COPY --chown=cloudpulse:cloudpulse package.json ./

USER cloudpulse

ENV NODE_ENV=production
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD node -e "require('http').get('http://127.0.0.1:8080/healthz', r => process.exit(r.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"

CMD ["node", "src/server.js"]
