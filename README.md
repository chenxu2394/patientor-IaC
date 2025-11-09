# Patientor — Reproducible Azure deployment with Terraform

Single-container deployment of **Patientor** to Azure App Service using Terraform. No Azure Container Registry required; the app pulls a **public, digest-pinned GHCR** image.

---

## What this repository provides

- **IaC** for Azure:
  - Resource Group
  - App Service Plan (Linux, Free F1)
  - Linux Web App running a public GHCR image pinned by digest at `ghcr.io/chenxu2394/patientor@sha256:bce3a0d76278af7a13debce5105ac581d6eef220cb43b6d20dfb8889caf4ff5d`
- Terraform outputs with the application URL

---

## Application

- Separate front end and back end.
- Front end makes at least one HTTP request to the back end when loaded.

---

## Prerequisites

- Azure CLI
- Terraform >= 1.13.4
- Azure subscription and tenant IDs (set in `infra/terraform.tfvars`)

---

## Variables

Defined in `infra/variables.tf`. Provide values via `infra/terraform.tfvars`.

Required:

- `app_name` — globally unique Web App name (lowercase letters/numbers)
- `rg_name` — Resource Group name
- `location` — Azure region (e.g., `northeurope`, `westeurope`)
- `subscription_id` — Azure subscription ID
- `tenant_id` — Azure tenant ID

Image is pinned in Terraform; do not change.

A sample is provided in `infra/terraform.tfvars.example`.

---

## Quickstart (deterministic)

```sh
# Clone and enter the repo
git clone https://github.com/chenxu2394/patientor-IaC.git
cd infra

# Authenticate Azure CLI if not already
az login # or `az login --tenant TENANT_ID`

# Show subscription_id and tenant_id after login
az account show --query "{subscriptionId:id, tenantId:tenantId}"

# Create your tfvars and edit required values
cp terraform.tfvars.example terraform.tfvars
# Edit only:
# - subscription_id, tenant_id
# - app_name (globally unique)
# - rg_name
# - location

# Deploy (idempotent converge)
terraform init -reconfigure
terraform apply -auto-approve

# Retrieve the app URL
terraform output webapp_url

# Idempotency check (should report no changes)
terraform apply -auto-approve
```

---

## Destroy

```sh
cd infra
terraform destroy -auto-approve
```

---

## Troubleshooting

**- Subscription ID could not be determined**  
Ensure `infra/terraform.tfvars` includes correct `subscription_id` and `tenant_id`, and that `az login` succeeded (`az account show`).

**- 409 “No available instances to satisfy this request” when creating the Plan**  
Change only `rg_name` and re-apply, or change `location` (e.g., `northeurope` ↔ `westeurope`) and re-apply.

**- 404 during Plan/Web App creation (eventual consistency)**  
This configuration waits between RG → Plan and Plan → Web App. If a transient 404 still occurs, re-run `terraform apply`.

**- Name already in use**  
`app_name` must be globally unique. Adjust and re-apply.

**- Deployment errors mention `Microsoft.Web` not registered**

```sh
# Run
az provider show -n Microsoft.Web --query registrationState -o tsv
az provider register --namespace Microsoft.Web
# wait until it shows "Registered"
```
