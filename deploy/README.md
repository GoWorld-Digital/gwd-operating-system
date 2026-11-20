# Retired Deployment Proposal — DO NOT EXECUTE

The files in this directory are from an earlier GWD deployment design. They are not verified current services, approved production manifests or an operational runbook.

Do not run Compose, shell scripts, SQL initialization, Caddy configuration or deployment commands from this directory. Do not connect credentials, domains, databases or customer data to these files.

Any reuse requires:
- an observed inventory of the current host and services;
- proof of ownership and isolation from AtlasHub, AtlasClub and client environments;
- review of ports, network exposure, secrets, persistence, backups and data classification;
- a new approved deployment specification, security review and rollback plan;
- a separate human release authorization.

A file existing here does not prove that its service is deployed. A service being absent from this repository does not prove that it is safe to remove.

Current institutional authority: [GWD Venture Studio](https://github.com/GoWorld-Digital/gwd-venture-studio). Technical Ops Core: [gwd-core](https://github.com/GoWorld-Digital/gwd-core).
