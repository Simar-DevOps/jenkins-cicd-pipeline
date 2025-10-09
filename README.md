[![tf-ci](https://github.com/Simar-DevOps/azure-static-website-mini/actions/workflows/tf-ci.yml/badge.svg)](https://github.com/Simar-DevOps/azure-static-website-mini/actions/workflows/tf-ci.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)

# Azure Static Website → Terraform & Bicep (Validate-only CI)

> **No-cost mode:** CI runs `terraform fmt`, `init -backend=false`, and `validate` only. No resources are created by default.

---

## What’s here
- `./terraform/versions.tf` — Terraform + `azurerm` provider pin  
- `./terraform/variables.tf` — RG/location/unique storage account name  
- `./terraform/main.tf` — RG + Storage Account + `azurerm_storage_account_static_website` + upload `index.html`/`404.html`  
- `./terraform/outputs.tf` — web endpoint + names  
- `./bicep/main.bicep` — enable static website (no file uploads)  
- `./.github/workflows/tf-ci.yml` — CI: **fmt → init(-backend=false) → validate**  
- `./docs/az900-crash-notes.md` — AZ-900 crash notes (key services & concepts)

---

## Pipeline stages (CI)
1. **Checkout**
2. **Terraform fmt** (enforce style)
3. **Terraform init** (no backend)
4. **Terraform validate** (syntax/schema)  
   > **No `plan`/`apply` in CI** — keeps costs at zero.

---

## Prerequisites
**None** for CI (validate-only).

**Optional local deploy needs:**
- Azure CLI (`az`)
- Terraform ≥ 1.6
- Any Azure subscription

---

## Quick start (CI)
Push to `main` or open a PR → GitHub Actions runs **fmt/init/validate** and stays green without deploying.

---

## Quick start (optional local Terraform deploy)

### Login + create demo RG
```bash
az login
az group create -n rg-azure-staticweb-demo -l eastus

# Deploy
cd terraform
terraform init
terraform plan -var "storage_account_name=<globally-unique-lowercase-3to24>"
terraform apply -auto-approve -var "storage_account_name=<globally-unique-lowercase-3to24>"
# Endpoint
terraform output -raw static_site_url

Quick start (optional Bicep enablement)
az login
az group create -n rg-azure-staticweb-demo -l eastus
az deployment group create \
  --resource-group rg-azure-staticweb-demo \
  --template-file ./bicep/main.bicep \
  --parameters storageAccountName=<globally-unique-lowercase>

Cleanup (if you deployed locally)
cd terraform
terraform destroy -auto-approve -var "storage_account_name=<same-name>"
az group delete -n rg-azure-staticweb-demo -y

Notes
- Validate-only CI by design to avoid charges
- Switch to OIDC later for safe deploys from Actions (azure/login@v2 + repo secrets AZURE_CLIENT_ID / AZURE_TENANT_ID / AZURE_SUBSCRIPTION_ID)
- AZ-900 refresher: see docs/az900-crash-notes.md

Contributing
Branching: feature/*, fix/*, chore/*
Commits: Conventional Commits (e.g., feat(terraform): enable static website)
PRs: Keep them small. Use the PR template. Note risk & rollback.

Local checks (before pushing)
cd terraform
terraform fmt -recursive
terraform init -backend=false
terraform validate
