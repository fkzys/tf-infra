# tf-infra

![License](https://img.shields.io/github/license/rpPH4kQocMjkm2Ve/tf-infra)

Cloudflare DNS infrastructure as code — zone and DNS records managed via Terraform with SOPS-encrypted secrets.

## How it works

```
direnv allow / source .envrc
        ↓
  1. SOPS decrypts age-encrypted secrets
  2. Terraform Cloud token exported to env
  3. terraform plan / apply
        ↓
  Cloudflare zone + DNS records converged
```

All sensitive values (API tokens, IPs, domain) are stored in `secrets.enc.yaml`, encrypted with [age](https://github.com/FiloSottile/age) via [SOPS](https://github.com/getsops/sops). Terraform reads them at plan/apply time through the `carlpett/sops` provider.

## What it manages

| Resource type | Records |
|---------------|---------|
| **Zone** | One Cloudflare zone (full DNS setup) |
| **A** | `instance1–4`, `meet`, `metrics3`, `metrics4`, root (`@`) |
| **AAAA** | `metrics3`, `metrics4` |
| **CNAME** | `cloud`, `element`, `matrix`, `matrix-admin`, `metrics1`, `metrics2`, `turn1`, `turn2` |

Records for `metrics3` and `metrics4` are proxied through Cloudflare. All others are DNS-only.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) ≥ 1.0
- [SOPS](https://github.com/getsops/sops) ≥ 3.7
- [age](https://github.com/FiloSottile/age) — decryption key at `~/.age/key.txt` (or set `SOPS_AGE_KEY_FILE`)
- [direnv](https://direnv.net/) *(optional, autoloads `.envrc`)*
- Access to the `fkzys` Terraform Cloud organization

## Setup

1. **Clone the repository:**

   ```bash
   git clone <repo-url>
   cd cf-infra
   ```

2. **Ensure the age key is in place:**

   ```bash
   ls ~/.age/key.txt
   ```

   The key must match the recipient defined in `.sops.yaml`.

3. **Load environment (pick one):**

   ```bash
   # With direnv (automatic):
   direnv allow

   # Without direnv (manual):
   source .envrc
   ```

   This decrypts the Terraform Cloud token from `secrets.enc.yaml` and exports it as `TF_TOKEN_app_terraform_io`.

4. **Initialize Terraform:**

   ```bash
   terraform init
   ```

5. **Plan and apply:**

   ```bash
   terraform plan
   terraform apply
   ```

## Secrets management

Secrets are encrypted with SOPS + age. The encrypted file `secrets.enc.yaml` contains:

| Key | Description |
|-----|-------------|
| `cloudflare_api_token` | Cloudflare API token for DNS management |
| `cloudflare_account_id` | Cloudflare account ID |
| `terraform_cloud_token` | Terraform Cloud API token |
| `domain` | Domain name |
| `ip_instance{1–4}_v4` | IPv4 addresses for instances 1–4 |
| `ip_instance{3,4}_v6` | IPv6 addresses for instances 3–4 |

**Editing secrets:**

```bash
sops secrets.enc.yaml
```

**Adding a new secret:**

```bash
sops secrets.enc.yaml
# Add your key-value pair in the editor, save, and exit
```

SOPS configuration (`.sops.yaml`) encrypts all `*.enc.yaml` files with the age recipient key.

## Project structure

| File | Role |
|------|------|
| `main.tf` | Terraform configuration — providers, zone, DNS records |
| `secrets.enc.yaml` | SOPS-encrypted secrets (API tokens, IPs, domain) |
| `.envrc` | direnv config — exports age key path and Terraform Cloud token |
| `.sops.yaml` | SOPS config — age recipient for encryption |
| `.terraform.lock.hcl` | Terraform provider lock file |
| `.gitignore` | Excludes `.terraform/`, state files, `terraform.tfvars` |

## Providers

| Provider | Version | Purpose |
|----------|---------|---------|
| [cloudflare/cloudflare](https://registry.terraform.io/providers/cloudflare/cloudflare/latest) | `~> 5.18.0` | Zone and DNS record management |
| [carlpett/sops](https://registry.terraform.io/providers/carlpett/sops/latest) | `~> 1.4.1` | Decrypt SOPS-encrypted secrets |

State is stored remotely in [Terraform Cloud](https://app.terraform.io/) (organization `fkzys`, workspace `cf-infra`).
