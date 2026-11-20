# GoWorld.Digital — AI-Native Operating System

> **GWD RECONCILIATION NOTICE — 20 NOV 2026**  
> **LEGACY / NON-GOVERNING OPERATING-ARCHITECTURE PROPOSAL.** This repository contains an earlier six-department, AWS/Atlas-Harness and operational architecture description. It is not the current constitution, portfolio authority or verified inventory of deployed resources. Preserve it for technical due diligence. A separate branch, security/day0-disable-auto-terraform-apply-20261120, indicates a Terraform safety change proposal and must be preserved and reviewed. The related [PR #1](https://github.com/GoWorld-Digital/gwd-operating-system/pull/1) is open and proposes removing automatic Terraform apply from main; it states that it makes no AWS changes. Any claimed cloud resource, domain, service, database, task system or integration must be independently verified before use, migration or retirement. Current institutional policy is in [gwd-venture-studio](https://github.com/GoWorld-Digital/gwd-venture-studio); operational implementation belongs in [gwd-core](https://github.com/GoWorld-Digital/gwd-core), subject to approved mandates.

---


> **Operated by:** `ATLASHUB DIGITAL LTD` (UK Companies House `#17379237`)  
> **Model:** Autonomous Venture Foundry & Service-as-a-Software Platform  
> **Cloud Account:** AWS `854784157482` (`us-east-2`) | **Tenant:** `gwd`

---

## Overview

**GoWorld.Digital (GWD)** is an AI-Native venture foundry and Service-as-a-Software platform operated by **ATLASHUB DIGITAL LTD**.  
This repository (`GoWorld-Digital/gwd-operating-system`) is the canonical source of truth for GWD's **cloud infrastructure (IaC)**, **production container stack**, and **organizational architecture**.

---

## The 6 Agentic Departments

| # | Department | Core Mandate | Key Surfaces |
|---|---|---|---|
| **1** | **Executive PMO** | Strategic alignment, Daily Pulse reporting, `ops.tasks` orchestration, and human-in-the-loop approval gates. | `ops.goworld.digital`, GitHub Projects |
| **2** | **Technology Foundry** | Open-source scouting, due diligence, license/security auditing, and rapid MVP-to-SaaS productization. | `api.goworld.digital`, `gwd-core` |
| **3** | **Radar Tech & Media** | Daily tech intelligence, verified briefings, video/editorial scripts, and multi-channel distribution. | `gwd-media-assets-prod` (S3) |
| **4** | **Academy & Community** | Applied AI education, playbooks, community cohorts, and developer enablement. | `explore.goworld.digital` |
| **5** | **Revenue & CRM** | Inbound lead capture, WhatsApp/Telegram/Web chat qualification, and AI-native pipeline execution. | `crm.goworld.digital`, `gwd-crm-os` |
| **6** | **Memory Ops** | Dual-tier semantic memory (`executive` vs `operational`), Obsidian Vault sync, and Amazon Titan v2 (`1024`-dim) indexing. | `gwd-vault-sync-prod` (S3), `pgvector` |

---

## The 3 Operational Circuits

```
┌───────────────────────────────────────────────────────────────────────────┐
│ 1. INTELLIGENCE & FOUNDRY CIRCUIT                                         │
│    Radar Scouting ──▶ Due Diligence ──▶ Product Thesis ──▶ MVP & SaaS     │
├───────────────────────────────────────────────────────────────────────────┤
│ 2. REVENUE & GROWTH CIRCUIT                                               │
│    Radar Media / Academy ──▶ Lead Capture ──▶ GWD CRM-OS ──▶ Conversion   │
├───────────────────────────────────────────────────────────────────────────┤
│ 3. MEMORY & GOVERNANCE CIRCUIT                                            │
│    Execution & Telemetry ──▶ Vault + GBrain (Titan v2) ──▶ Executive PMO  │
└───────────────────────────────────────────────────────────────────────────┘
```

1. **Intelligence & Foundry Circuit:** Continuously scans open-source ecosystems, scores candidates (`GWD-TECH-*`), validates security and licensing, and promotes winning theses (`GWD-PROD-*`) into production software.
2. **Revenue & Growth Circuit:** Turns editorial intelligence and community trust into qualified pipeline via `crm.goworld.digital` and multi-tenant chat workflows.
3. **Memory & Governance Circuit:** Persists every mission state in `ops.tasks`, indexes institutional knowledge into `gbrain.knowledge_nodes` (`vector(1024)`), and enforces human approval before external commitments or production deployments.

---

## Repository Structure

```text
gwd-operating-system/
├── .github/workflows/
│   └── terraform-plan.yml      # OIDC-authenticated Terraform Plan (PR) & Apply (main)
├── infra/
│   └── phase1/
│       ├── main.tf             # VPC, EC2 (gwd-core), EIP, S3 (gwd-vault-sync-prod, gwd-media-assets-prod)
│       ├── variables.tf        # Project variables & ATLASHUB DIGITAL LTD tags
│       └── iam.tf              # GitHub OIDC provider/role + EC2 Instance Profile
├── deploy/
│   ├── Caddyfile               # Auto-HTTPS reverse proxy (ops, api, crm.goworld.digital)
│   ├── docker-compose.yml      # pgvector:pg16, orchestrator, gwdbot, telemetry, caddy
│   ├── deploy.sh               # Zero-downtime Secrets Manager + Compose deploy script
│   └── init.sql                # ops.tasks, gbrain (vector 1024 + memory_tier), soul, crm
└── README.md
```

---

## Security & Governance Principles

- **Zero Long-Lived Keys in CI:** GitHub Actions authenticates to AWS via OIDC locked exclusively to `repo:GoWorld-Digital/gwd-operating-system:*`.
- **IMDSv2 Enforced:** EC2 metadata requires session tokens; runtime secrets are pulled from AWS Secrets Manager into `tmpfs` (`/run/gwd-secrets`).
- **Dual-Tier Memory Separation:** `executive` and `operational` memory tiers are explicitly enforced in `gbrain` and `soul`.
- **Human-in-the-Loop Gates:** Production Terraform applies and external commercial/financial actions require explicit human approval.
