#!/usr/bin/env bash
set -euo pipefail

# Usage: remote_setup.sh <APP_NAME> [APP_PORT]
APP_NAME="${1:-flask-hello}"
APP_PORT="${2:-8000}"
APP_DIR="/opt/${APP_NAME}"
SRC_DIR="/tmp/src"

# Always make sure required packages are present (Ubuntu 22.04/24.04 safe)
sudo apt-get update -y
# Try both the meta and versioned venv packages; ignore errors if one doesn't exist
sudo apt-get install -y python3 python3-pip || true
sudo apt-get install -y python3-venv || true
sudo apt-get install -y python3.12-venv || true

# If venv still missing, fail with a clear message
if ! python3 -m venv --help >/dev/null 2>&1; then
  echo "ERROR: python3 venv module not available. Install python3-venv (or python3.12-venv) and retry."
  exit 1
fi

# Seed/refresh code
sudo rm -rf "${APP_DIR}"
sudo mkdir -p "${APP_DIR}"
sudo cp -r "${SRC_DIR}/app" "${APP_DIR}/"
sudo cp -r "${SRC_DIR}/deploy" "${APP_DIR}/"

# Python venv + deps
if [[ ! -d "${APP_DIR}/venv" ]]; then
  sudo python3 -m venv "${APP_DIR}/venv"
fi
sudo "${APP_DIR}/venv/bin/pip" install --upgrade pip
sudo "${APP_DIR}/venv/bin/pip" install -r "${APP_DIR}/app/requirements.txt" gunicorn

# systemd unit
SERVICE_FILE="/etc/systemd/system/${APP_NAME}.service"
sudo bash -c "cat > \"$SERVICE_FILE\" <<UNIT
[Unit]
Description=${APP_NAME} Flask App
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=${APP_DIR}/app
Environment=PYTHONUNBUFFERED=1
ExecStart=${APP_DIR}/venv/bin/gunicorn -w 2 -b 0.0.0.0:${APP_PORT} wsgi:app
Restart=always

[Install]
WantedBy=multi-user.target
UNIT"

sudo systemctl daemon-reload
sudo systemctl enable "${APP_NAME}"
sudo systemctl restart "${APP_NAME}"

echo "Deployed ${APP_NAME} on port ${APP_PORT}."
