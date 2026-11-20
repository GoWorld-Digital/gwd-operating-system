# Retired Terraform Proposal — DO NOT EXECUTE

The Terraform files in this directory belong to a superseded GWD infrastructure proposal. They are not an approved infrastructure baseline, current cloud inventory, production deployment definition or authorization to create, modify or destroy resources.

**Do not run terraform init, plan, apply, destroy, import or state migration from this directory.** The former GitHub Actions Terraform workflow has been removed. No automated AWS plan/apply path is retained here.

Before any future infrastructure work:
1. Independently inventory actual cloud accounts, resources, ownership, state backends, backups, DNS, IAM and external dependencies.
2. Reconcile actual resources with the current GWD Genesis Clean Room mandate.
3. Create a new, private and approved infrastructure repository from verified facts.
4. Use a reviewed plan, least-privilege identity, independent human approval, rollback and restore evidence.
5. Obtain a separate release decision.

Do not infer that a resource exists because it appears in Terraform, or that it is unused because the proposal is retired. Never destroy resources based only on this repository.

Current institutional authority: [GWD Venture Studio](https://github.com/GoWorld-Digital/gwd-venture-studio). Technical Ops Core: [gwd-core](https://github.com/GoWorld-Digital/gwd-core).
