# Jenkins CI/CD → EC2 (Flask via SSH + systemd)

[![License](https://img.shields.io/badge/License-MIT-informational)](LICENSE)

## What’s here
- `./Jenkinsfile` — build → test (pytest) → deploy to EC2 via SSH → post-deploy health check
- `./jenkins/basic-security.groovy` — baseline hardening for a fresh Jenkins
- `./deploy/remote_setup.sh` — creates venv, installs deps, configures `systemd` service
- `./app/` — minimal Flask demo app

Pipeline stages:
- Checkout
- Test (pytest in a venv inside Jenkins)
- Deploy (scp app/ + deploy/ to EC2; remote script sets up venv & systemd)
- Post-deploy health check

## Prerequisites
- Docker Desktop
- Ubuntu 22.04 EC2 instance
  - Inbound 22/tcp (from your IP)
  - Inbound 8000/tcp (0.0.0.0/0 for demo)
  - Key pair (.pem) available
- Public IP/DNS of the EC2 instance

## Quick start
1) Start Jenkins:
cd jenkins
docker compose build
docker compose up -d
Open http://localhost:8080 (demo admin/admin)

2) In Jenkins:
- Credentials → Global:
  - Secret text (ID: `ec2-host`) = your EC2 IP or DNS
  - SSH Username with private key (ID: `ec2-ssh-key`) = user `ubuntu`, paste your PEM

3) Create Job:
- New Item → Pipeline `flask-ec2-deploy`
- Pipeline from SCM → Git → your repo → Script Path: `Jenkinsfile`
- Trigger: Poll SCM `H/5 * * * *` (or GitHub webhook if exposed)

4) Build → Visit `http://<EC2_PUBLIC_IP>:8000/health` → `OK`
