# tf-infra

![License](https://img.shields.io/github/license/fkzys/tf-infra)
[![Spec](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/fkzys/specs/refs/heads/main/version.json&maxAge=300)](https://github.com/fkzys/specs)

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
| **A** | `instance2`, `instance3`, root (`@`) |
| **CNAME** | `cloud`, `element`, `matrix`, `matrix-admin`, `matrix-rtc`, `meet`, `meet-test`, `metrics2`, `metrics3` |

All CNAMEs point to `instance2.<domain>`, except `metrics3`, which points to `instance3.<domain>`. Only `metrics3` is proxied through Cloudflare; all other records are DNS-only. The root (`@`) A record uses the `instance2` IPv4 address.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) ≥ 1.1 (the `cloud` block is used)
- [SOPS](https://github.com/getsops/sops) ≥ 3.7
- [age](https://github.com/FiloSottile/age) — decryption key at `~/keys/age/sops-pq.txt` by default (override with `SOPS_AGE_KEY_FILE`)
- [direnv](https://direnv.net/) *(optional, autoloads `.envrc`)*
- Access to the `fkzys` Terraform Cloud organization

## Setup

1. **Clone the repository:**

   ```bash
   git clone <repo-url>
   cd tf-infra
   ```

2. **Ensure the age key is in place:**

   ```bash
   ls ~/keys/age/sops-pq.txt
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
| `ip_instance2_v4` | IPv4 address for instance 2 (also used for the root A record) |
| `ip_instance3_v4` | IPv4 address for instance 3 |

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

State is stored remotely in [Terraform Cloud](https://app.terraform.io/) (organization `fkzys`, workspace `cf-infrav2`).
