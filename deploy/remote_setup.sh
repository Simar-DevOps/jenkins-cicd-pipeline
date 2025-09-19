#!/usr/bin/env bash
set -euo pipefail

# Usage: remote_setup.sh <APP_NAME> [APP_PORT]
APP_NAME="${1:-flask-hello}"
APP_PORT="${2:-8000}"
APP_DIR="/opt/${APP_NAME}"
SRC_DIR="/tmp/src"

# Ensure base packages
if ! command -v python3 >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y python3 python3-venv python3-pip
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
