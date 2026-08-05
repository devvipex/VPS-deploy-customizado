# ADR 0001: Choosing Docker Swarm over Kubernetes for Low-Cost MVP Infrastructure

* **Status:** Accepted
* **Deciders:** System Architect / Engineering Lead
* **Date:** 2026-08-05

---

## Context and Problem Statement

When deploying new client MVPs (Minimum Viable Products), startups and early-stage clients require a cost-effective, high-availability, and low-maintenance infrastructure stack. Managing full Kubernetes clusters (EKS, GKE, AKS) adds significant operational overhead, complex ingress controllers, and high monthly baseline costs (~$100+/month minimum for cluster control planes).

The primary goal is to provide a single-command deployment pipeline on a low-cost VPS ($5–$20/month) with automated SSL, container orchestration, databases, messaging, CI/CD, and offline-first mobile-friendly applications.

---

## Decision Drivers

* **Infrastructure Cost:** Must run on a single $5–$20/month VPS (DigitalOcean, Hetzner, AWS EC2).
* **Operational Simplicity:** Zero dedicated Kubernetes DevOps engineers required for maintenance.
* **Rapid Onboarding:** Developers should clone the repository, run a setup script, and deploy within minutes.
* **Natively Integrated Ingress & SSL:** Traefik integration for automatic Let's Encrypt certificates.

---

## Considered Options

1. **Kubernetes (k8s / k3s / minikube)**
2. **Docker Swarm + Traefik**
3. **Single Standalone Docker Compose Instance**

---

## Decision Outcome

**Chosen Option:** **Docker Swarm + Traefik**

### Positive Consequences
* **Low Cost:** Operates efficiently on single-node or multi-node VPS instances starting at 2GB RAM.
* **Built-in Orchestration:** Native rolling updates (`docker service update`), health checks, and overlay networks.
* **Low Maintenance:** Zero Kubernetes control plane upgrades or etcd management required.
* **Seamless Developer Experience (DX):** Standard `docker-compose.yml` / `docker-stack.yml` syntax.

### Negative Consequences / Mitigation
* **Ecosystem Scale:** Less plugin ecosystem compared to Helm charts.
  * *Mitigation:* Pre-packaged stacks for Jenkins, Portainer, Mongo, Redis, RabbitMQ, MinIO, n8n, and Postvector.
