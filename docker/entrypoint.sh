#!/bin/sh
set -e

echo "🥚 __EGG_APP_NAME__ starting up..."

# ── Generate config/docker.yaml from environment variables ──────────────────
mkdir -p /app/config
cat > /app/config/docker.yaml <<EOF
namespace: ${EGG_NAMESPACE:?EGG_NAMESPACE is required}
name: ${EGG_APP_NAME:?EGG_APP_NAME is required}
semver: ${EGG_VERSION:-0.0.1}
license: ${EGG_LICENSE:-Apache-2.0}
copyright:
    year: ${EGG_YEAR:-2025}
    author: ${EGG_AUTHOR:-unknown}
server:
    auth0:
        domain: ${EGG_AUTH0_DOMAIN:?EGG_AUTH0_DOMAIN is required}
        audience: ${EGG_AUTH0_AUDIENCE:?EGG_AUTH0_AUDIENCE is required}
        client_id: ${EGG_AUTH0_CLIENT_ID:?EGG_AUTH0_CLIENT_ID is required}
        client_secret: ${EGG_AUTH0_CLIENT_SECRET:?EGG_AUTH0_CLIENT_SECRET is required}
    port: ${EGG_PORT:-8080}
    frontend:
        dir: ${EGG_FRONTEND_DIR:-web/dist}
        api: ${EGG_FRONTEND_API:-web/src/api}
database:
    url: ${EGG_DB_URL:?EGG_DB_URL is required}
    sqlc:
        repository: ${EGG_SQLC_REPO:-db/repository}
        schema: ${EGG_SQLC_SCHEMA:-db/migrations}
        sql_or_go: ${EGG_SQLC_TYPE:-go}
    queries: ${EGG_DB_QUERIES:-db/queries}
    migration:
        protocol: ${EGG_MIGRATION_PROTO:-pgx5}
        destination: ${EGG_MIGRATION_DEST:-db/migrations}
cache:
    url: ${EGG_CACHE_URL:-redis://cache:6379}
s3:
    url: ${EGG_S3_URL:-http://minio:9000}
    access: ${EGG_S3_ACCESS:-minioadmin}
    secret: ${EGG_S3_SECRET:-minioadmin123}
    secure: ${EGG_S3_SECURE:-false}
EOF

echo "🥚 Config written to /app/config/docker.yaml"

# ── Wait for PostgreSQL ──────────────────────────────────────────────────────
# (docker-compose healthchecks handle this, but this is a belt-and-suspenders guard)
DB_HOST="${DB_HOST:-db}"
DB_PORT="${DB_PORT:-5432}"

echo "🥚 Verifying PostgreSQL at ${DB_HOST}:${DB_PORT}..."
i=0
until nc -z "${DB_HOST}" "${DB_PORT}" 2>/dev/null; do
    i=$((i + 1))
    if [ "$i" -ge 30 ]; then
        echo "❌ PostgreSQL not reachable after 60s. Exiting."
        exit 1
    fi
    echo "  Attempt ${i}/30: not ready, retrying in 2s..."
    sleep 2
done
echo "🥚 PostgreSQL is reachable."

# ── Run migrations ───────────────────────────────────────────────────────────
echo "🥚 Running database migrations..."
/app/__EGG_APP_NAME__ db up -e docker
echo "🥚 Migrations complete."

# ── Start server ─────────────────────────────────────────────────────────────
echo "🥚 Starting server..."
exec /app/__EGG_APP_NAME__ -e docker
