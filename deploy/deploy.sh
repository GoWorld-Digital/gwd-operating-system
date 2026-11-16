#!/usr/bin/env bash
# /opt/gwd/deploy.sh
# Zero-downtime pull-and-restart for GoWorld.Digital (GWD Operating System)
# Run as: sudo -u ubuntu bash /opt/gwd/deploy.sh [VERSION_TAG]

set -euo pipefail

GWD_DIR="/opt/gwd"
SECRETS_DIR="/run/gwd-secrets"
AWS_REGION="us-east-2"
GWD_VERSION="${1:-latest}"

echo "[gwd-deploy] Starting deployment — version: ${GWD_VERSION}"

# ── 1. Pull secrets from AWS Secrets Manager into tmpfs ──────────────────────
mkdir -p "${SECRETS_DIR}"
chmod 700 "${SECRETS_DIR}"

echo "[gwd-deploy] Fetching secrets from AWS Secrets Manager..."

aws secretsmanager get-secret-value \
  --region "${AWS_REGION}" \
  --secret-id "gwd/postgres/db_password" \
  --query 'SecretString' \
  --output text > "${SECRETS_DIR}/db_password.txt"
chmod 600 "${SECRETS_DIR}/db_password.txt"

export POSTGRES_PASSWORD
POSTGRES_PASSWORD=$(cat "${SECRETS_DIR}/db_password.txt")
export GWD_VERSION

echo "[gwd-deploy] Secrets loaded into tmpfs."

# ── 2. Pull latest images ─────────────────────────────────────────────────────
echo "[gwd-deploy] Pulling Docker images (version: ${GWD_VERSION})..."
cd "${GWD_DIR}"

docker compose pull --quiet

# ── 3. Rolling restart (zero downtime) ───────────────────────────────────────
echo "[gwd-deploy] Restarting services..."

docker compose up -d --no-deps postgres
docker compose up -d --no-deps orchestrator
docker compose up -d --no-deps gwdbot
docker compose up -d --no-deps telemetry
docker compose up -d --no-deps caddy

# ── 4. Health check ───────────────────────────────────────────────────────────
echo "[gwd-deploy] Waiting for health checks..."
sleep 10

HEALTHY=true
for SERVICE in orchestrator bot-gateway telemetry; do
  STATUS=$(docker inspect --format='{{.State.Health.Status}}' "gwd-${SERVICE}" 2>/dev/null || echo 'unknown')
  if [[ "${STATUS}" != "healthy" ]]; then
    echo "[gwd-deploy] WARNING: gwd-${SERVICE} is ${STATUS}"
    HEALTHY=false
  else
    echo "[gwd-deploy] OK: gwd-${SERVICE} is healthy"
  fi
done

# ── 5. Cleanup old images ─────────────────────────────────────────────────────
docker image prune -f --filter "until=24h" > /dev/null 2>&1 || true

# ── 6. Wipe secrets from tmpfs ───────────────────────────────────────────────
rm -rf "${SECRETS_DIR}"
echo "[gwd-deploy] Secrets wiped from tmpfs."

if [[ "${HEALTHY}" == "true" ]]; then
  echo "[gwd-deploy] Deployment complete — all services healthy."
  exit 0
else
  echo "[gwd-deploy] Deployment complete with warnings — check unhealthy services."
  exit 1
fi
