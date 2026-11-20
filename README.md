# GWD Operating System — Retired Infrastructure Proposal

> **STATUS: RETIRED / NON-GOVERNING / DO NOT DEPLOY**  
> **Effective baseline:** 20 November 2026

This repository preserves an earlier six-department operating model and an unverified AWS/Terraform infrastructure proposal. It is not the current GWD operating system, constitution, portfolio authority, production inventory or deployment source.

## Current GWD identity

**GWD Genesis — AI Venture Studio**  
**One Intelligence. Multiple Runtimes. Independent Ventures.**

The current institutional model has three pillars: Governance, Ventures and Cortex.

Current authority:
- [Public identity and agent alignment](https://github.com/GoWorld-Digital/.github/tree/main/profile)
- [GWD Venture Studio — constitution and governance](https://github.com/GoWorld-Digital/gwd-venture-studio)
- [GWD Venture Portfolio — opportunities and approvals](https://github.com/GoWorld-Digital/gwd-venture-portfolio)
- [GWD Core — Ops Core implementation](https://github.com/GoWorld-Digital/gwd-core)
- [GWD Knowledge Vault](https://github.com/GoWorld-Digital/gwd-knowledge-vault)

## Safety status

- The automatic Terraform apply job was removed from the GitHub Actions workflow and the security correction was merged to main.
- The remaining Terraform plan workflow still uses AWS OIDC and repository secrets. It is not evidence of a verified or approved cloud deployment.
- No Terraform plan, apply, destroy, import, state migration, DNS change, IAM change or cloud-resource mutation is authorized by this README.
- Do not execute any scripts, Compose files, Terraform modules or SQL from this repository.
- Any cloud resource, account, IP, domain, bucket, database or service mentioned in historical files must be independently verified before use or retirement.
- Do not add secrets, customer data, production endpoints or current infrastructure credentials here.

## Retirement rules

This repository is frozen pending a read-only dependency and resource audit. Its old six-department model, Atlas-Harness assumptions, fixed AWS topology and proposed operational circuits are not current GWD policy.

Preserve the files temporarily only to identify whether any actual resource, external automation, backup or deployment still depends on them. Once that verification is complete, archive the repository or remove obsolete implementation files under a controlled retirement plan.

**GWD Genesis — One Intelligence. Multiple Runtimes. Independent Ventures.**
