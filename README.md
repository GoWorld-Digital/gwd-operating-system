# GoWorld.Digital — AI-Native Operating System

> **GWD RECONCILIATION NOTICE — 20 NOV 2026**  
> **LEGACY / NON-GOVERNING OPERATING-ARCHITECTURE PROPOSAL.** This repository contains an earlier six-department, AWS/Atlas-Harness and operational architecture description. It is not the current constitution, portfolio authority or verified inventory of deployed resources. Preserve it for technical due diligence. A separate branch, security/day0-disable-auto-terraform-apply-20261120, indicates a Terraform safety change proposal and must be preserved and reviewed. The related [PR #1](https://github.com/GoWorld-Digital/gwd-operating-system/pull/1) is open and proposes removing automatic Terraform apply from main; it states that it makes no AWS changes. Any claimed cloud resource, domain, service, database, task system or integration must be independently verified before use, migration or retirement. Current institutional policy is in [gwd-venture-studio](https://github.com/GoWorld-Digital/gwd-venture-studio); operational implementation belongs in [gwd-core](https://github.com/GoWorld-Digital/gwd-core), subject to approved mandates.

---


> **Historical model:** Autonomous Venture Foundry & Service-as-a-Software Platform  
> **Tenant label in prior design:** `gwd`  
> **Legal operator / investment vehicle:** not established by this repository; see the Decision Continuity Register.

---

## Overview

**GoWorld.Digital (GWD)** is currently presented as **GWD Genesis — AI Venture Studio**, organized around Governance, Ventures and Cortex. This repository preserves a prior infrastructure/operating-model proposal. It is not the current constitution, not the portfolio authority and not evidence that its described cloud resources or production services are deployed. The prior GWD-GOV-0001 Charter names ATLASHUB DIGITAL LTD; the current legal operator and any investment/contracting vehicle remain subject to explicit transition and qualified legal review.

---

## Historical six-department proposal (not the current organization)

| # | Department | Core Mandate | Key Surfaces |
|---|---|---|---|
| **1** | **Executive PMO** | Strategic alignment, Daily Pulse reporting, `ops.tasks` orchestration, and human-in-the-loop approval gates. | `ops.goworld.digital`, GitHub Projects |
| **2** | **Technology Foundry** | Open-source scouting, due diligence, license/security auditing, and rapid MVP-to-SaaS productization. | `api.goworld.digital`, `gwd-core` |
| **3** | **Radar Tech & Media** | Daily tech intelligence, verified briefings, video/editorial scripts, and multi-channel distribution. | `gwd-media-assets-prod` (S3) |
| **4** | **Academy & Community** | Applied AI education, playbooks, community cohorts, and developer enablement. | `explore.goworld.digital` |
| **5** | **Revenue & CRM** | Inbound lead capture, WhatsApp/Telegram/Web chat qualification, and AI-native pipeline execution. | `crm.goworld.digital`, `gwd-crm-os` |
| **6** | **Memory Ops** | Dual-tier semantic memory (`executive` vs `operational`), Obsidian Vault sync, and Amazon Titan v2 (`1024`-dim) indexing. | `gwd-vault-sync-prod` (S3), `pgvector` |

---

## Historical proposed operational circuits (not verified live workflows)

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
│   └── terraform-plan.yml      # Historical workflow; see open security PR #1 before any use
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

## Prior proposed security controls — not verified implementation evidence

- The earlier design proposed GitHub Actions OIDC for AWS access; verify trust policy and permissions before use.
- The earlier design described IMDSv2 and AWS Secrets Manager; verify the actual resources and runtime configuration.
- The earlier design described `executive` and `operational` memory tiers; this does not ratify Atlas-Cortex internals or prove isolation.
- The earlier design described human approval gates. The open [PR #1](https://github.com/GoWorld-Digital/gwd-operating-system/pull/1) proposes removing automatic Terraform apply from main; review and merge decisions remain pending.
