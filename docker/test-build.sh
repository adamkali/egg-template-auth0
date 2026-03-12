#!/bin/sh
# test-build.sh
#
# Simulates what egg_cli will do: copies the template to a temp directory,
# replaces all __EGG_*__ placeholders with real values, then runs docker compose.
#
# Usage:
#   chmod +x docker/test-build.sh
#   ./docker/test-build.sh
#
# To tear down after testing:
#   docker compose -f /tmp/egg-test-build/images/docker-compose.yaml down -v

set -e

# ── Configure test values ────────────────────────────────────────────────────
EGG_NAMESPACE="github.com/egg-test/myapp"
EGG_NAMESPACE_OWNER="egg-test"
EGG_APP_NAME="myapp"
EGG_VERSION="0.0.1"
EGG_LICENSE="Apache-2.0"
EGG_AUTHOR="Test User"
EGG_YEAR="2025"
EGG_PORT="8080"
EGG_AUTH0_DOMAIN="your-tenant.us.auth0.com"
EGG_AUTH0_AUDIENCE="https://your-tenant.us.auth0.com/api/v2/"
EGG_AUTH0_CLIENT_ID="your-client-id"
EGG_AUTH0_CLIENT_SECRET="your-client-secret"
EGG_MIGRATION_PROTO="postgres"
EGG_MIGRATION_DEST="db/migrations"
EGG_SQLC_REPO="db/repository"
EGG_SQLC_SCHEMA="db/migrations"
EGG_SQLC_TYPE="go"
EGG_DB_QUERIES="db/queries"
EGG_FRONTEND_DIR="web/dist"
EGG_FRONTEND_API="web/src/api"

POSTGRES_USER="postgres"
POSTGRES_PASSWORD="testpassword"
POSTGRES_DB="myappdb"
MINIO_ROOT_USER="minioadmin"
MINIO_ROOT_PASSWORD="minioadmin123"

# ── Copy template to a temp directory ───────────────────────────────────────
TEMPLATE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="/tmp/egg-test-build"

echo "🥚 Copying template to ${BUILD_DIR}..."
rm -rf "${BUILD_DIR}"
cp -r "${TEMPLATE_DIR}" "${BUILD_DIR}"

# ── Replace all __EGG_*__ placeholders in text files ─────────────────────────
echo "🥚 Substituting placeholders..."

# Binary extensions to skip
BINARY_EXTS="png jpg jpeg ico woff woff2 gif webp"

find "${BUILD_DIR}" -type f | while read -r FILE; do
    # Skip .git directory
    case "${FILE}" in */.git/*) continue ;; esac

    # Skip binary files
    EXT="${FILE##*.}"
    SKIP=0
    for BIN_EXT in ${BINARY_EXTS}; do
        if [ "${EXT}" = "${BIN_EXT}" ]; then
            SKIP=1
            break
        fi
    done
    if [ "${SKIP}" = "1" ]; then continue; fi

    # Check if file contains any placeholder
    if grep -q "__EGG_" "${FILE}" 2>/dev/null; then
        sed -i \
            -e "s|__EGG_NAMESPACE__|${EGG_NAMESPACE}|g" \
            -e "s|__EGG_NAMESPACE_OWNER__|${EGG_NAMESPACE_OWNER}|g" \
            -e "s|__EGG_APP_NAME__|${EGG_APP_NAME}|g" \
            -e "s|__EGG_VERSION__|${EGG_VERSION}|g" \
            -e "s|__EGG_LICENSE__|${EGG_LICENSE}|g" \
            -e "s|__EGG_AUTHOR__|${EGG_AUTHOR}|g" \
            -e "s|__EGG_YEAR__|${EGG_YEAR}|g" \
            -e "s|__EGG_PORT__|${EGG_PORT}|g" \
            -e "s|__EGG_AUTH0_DOMAIN__|${EGG_AUTH0_DOMAIN}|g" \
            -e "s|__EGG_AUTH0_AUDIENCE__|${EGG_AUTH0_AUDIENCE}|g" \
            -e "s|__EGG_AUTH0_CLIENT_ID__|${EGG_AUTH0_CLIENT_ID}|g" \
            -e "s|__EGG_AUTH0_CLIENT_SECRET__|${EGG_AUTH0_CLIENT_SECRET}|g" \
            -e "s|__EGG_MIGRATION_PROTO__|${EGG_MIGRATION_PROTO}|g" \
            -e "s|__EGG_MIGRATION_DEST__|${EGG_MIGRATION_DEST}|g" \
            -e "s|__EGG_SQLC_REPO__|${EGG_SQLC_REPO}|g" \
            -e "s|__EGG_SQLC_SCHEMA__|${EGG_SQLC_SCHEMA}|g" \
            -e "s|__EGG_SQLC_TYPE__|${EGG_SQLC_TYPE}|g" \
            -e "s|__EGG_DB_QUERIES__|${EGG_DB_QUERIES}|g" \
            -e "s|__EGG_FRONTEND_DIR__|${EGG_FRONTEND_DIR}|g" \
            -e "s|__EGG_FRONTEND_API__|${EGG_FRONTEND_API}|g" \
            "${FILE}"
    fi
done

# ── Generate .env for docker compose ────────────────────────────────────────
echo "🥚 Writing .env..."
cat > "${BUILD_DIR}/.env" <<EOF
EGG_NAMESPACE=${EGG_NAMESPACE}
EGG_APP_NAME=${EGG_APP_NAME}
EGG_VERSION=${EGG_VERSION}
EGG_LICENSE=${EGG_LICENSE}
EGG_AUTHOR=${EGG_AUTHOR}
EGG_YEAR=${EGG_YEAR}
EGG_PORT=${EGG_PORT}
EGG_AUTH0_DOMAIN=${EGG_AUTH0_DOMAIN}
EGG_AUTH0_AUDIENCE=${EGG_AUTH0_AUDIENCE}
EGG_AUTH0_CLIENT_ID=${EGG_AUTH0_CLIENT_ID}
EGG_AUTH0_CLIENT_SECRET=${EGG_AUTH0_CLIENT_SECRET}
EGG_MIGRATION_PROTO=${EGG_MIGRATION_PROTO}
EGG_MIGRATION_DEST=${EGG_MIGRATION_DEST}
EGG_SQLC_REPO=${EGG_SQLC_REPO}
EGG_SQLC_SCHEMA=${EGG_SQLC_SCHEMA}
EGG_SQLC_TYPE=${EGG_SQLC_TYPE}
EGG_DB_QUERIES=${EGG_DB_QUERIES}
EGG_FRONTEND_DIR=${EGG_FRONTEND_DIR}
EGG_FRONTEND_API=${EGG_FRONTEND_API}
POSTGRES_USER=${POSTGRES_USER}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_DB=${POSTGRES_DB}
MINIO_ROOT_USER=${MINIO_ROOT_USER}
MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD}
EOF

# ── Run docker compose ────────────────────────────────────────────────────────
echo "🥚 Launching docker compose from ${BUILD_DIR}..."
docker compose -f "${BUILD_DIR}/images/docker-compose.yaml" up --build

echo ""
echo "🥚 Done. To clean up: docker compose -f ${BUILD_DIR}/images/docker-compose.yaml down -v"
