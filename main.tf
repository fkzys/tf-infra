terraform {
  cloud {
    organization = "fkzys"
    workspaces {
      name = "cf-infra"
    }
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.18.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.4.1"
    }
  }
}

data "sops_file" "secrets" {
  source_file = "secrets.enc.yaml"
}

provider "cloudflare" {
  api_token = data.sops_file.secrets.data["cloudflare_api_token"]
}

locals {
  s       = data.sops_file.secrets.data
  domain  = local.s["domain"]
  zone_id = cloudflare_zone.main.id
}

# ─────────────────────────────────────────────
# Zone
# ─────────────────────────────────────────────

resource "cloudflare_zone" "main" {
  account = {
    id = local.s["cloudflare_account_id"]
  }
  paused = false
  type   = "full"
  name   = local.domain
}

# ─────────────────────────────────────────────
# A records
# ─────────────────────────────────────────────

resource "cloudflare_dns_record" "a_instance1" {
  content = local.s["ip_instance1_v4"]
  name    = "instance1"
  proxied = false
  ttl     = 1
  type    = "A"
  zone_id = local.zone_id
}

resource "cloudflare_dns_record" "a_instance2" {
  content = local.s["ip_instance2_v4"]
  name    = "instance2"
  proxied = false
  ttl     = 1
  type    = "A"
  zone_id = local.zone_id
}

resource "cloudflare_dns_record" "a_instance3" {
  content = local.s["ip_instance3_v4"]
  name    = "instance3"
  proxied = false
  ttl     = 1
  type    = "A"
  zone_id = local.zone_id
}

resource "cloudflare_dns_record" "a_instance4" {
  content = local.s["ip_instance4_v4"]
  name    = "instance4"
  proxied = false
  ttl     = 1
  type    = "A"
  zone_id = local.zone_id
}

resource "cloudflare_dns_record" "a_root" {
  content = local.s["ip_instance2_v4"]
  name    = local.domain
  proxied = false
  ttl     = 1
  type    = "A"
  zone_id = local.zone_id
}

# ─────────────────────────────────────────────
# AAAA records
# ─────────────────────────────────────────────

resource "cloudflare_dns_record" "aaaa_instance3" {
  content = local.s["ip_instance3_v6"]
  name    = "instance3"
  proxied = false
  ttl     = 1
  type    = "AAAA"
  zone_id = local.zone_id
}

resource "cloudflare_dns_record" "aaaa_instance4" {
  content = local.s["ip_instance4_v6"]
  name    = "instance4"
  proxied = false
  ttl     = 1
  type    = "AAAA"
  zone_id = local.zone_id
}

# ─────────────────────────────────────────────
# CNAME records
# ─────────────────────────────────────────────

resource "cloudflare_dns_record" "cname_cloud" {
  content = "instance2.${local.domain}"
  name    = "cloud"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  zone_id = local.zone_id
}

resource "cloudflare_dns_record" "cname_element" {
  content = "instance2.${local.domain}"
  name    = "element"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  zone_id = local.zone_id
}

resource "cloudflare_dns_record" "cname_matrix" {
  content = "instance2.${local.domain}"
  name    = "matrix"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  zone_id = local.zone_id
}

resource "cloudflare_dns_record" "cname_matrix_admin" {
  content = "instance2.${local.domain}"
  name    = "matrix-admin"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  zone_id = local.zone_id
}

resource "cloudflare_dns_record" "cname_meet" {
  content = "instance1.${local.domain}"
  name    = "meet"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  zone_id = local.zone_id
}

resource "cloudflare_dns_record" "cname_metrics1" {
  content = "instance1.${local.domain}"
  name    = "metrics1"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  zone_id = local.zone_id
}

resource "cloudflare_dns_record" "cname_metrics2" {
  content = "instance2.${local.domain}"
  name    = "metrics2"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  zone_id = local.zone_id
}

resource "cloudflare_dns_record" "cname_metrics3" {
  content = "instance3.${local.domain}"
  name    = "metrics3"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  zone_id = local.zone_id
}

resource "cloudflare_dns_record" "cname_metrics4" {
  content = "instance4.${local.domain}"
  name    = "metrics4"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  zone_id = local.zone_id
}

resource "cloudflare_dns_record" "cname_turn1" {
  content = "instance1.${local.domain}"
  name    = "turn1"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  zone_id = local.zone_id
}

resource "cloudflare_dns_record" "cname_turn2" {
  content = "instance2.${local.domain}"
  name    = "turn2"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  zone_id = local.zone_id
}
