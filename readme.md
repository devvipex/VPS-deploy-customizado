# 🚀 Custom VPS Deploy & Base MVP Stack

[![Language: English](https://img.shields.io/badge/Language-English-blue.svg)](./readme.md)
[![Idioma: Português](https://img.shields.io/badge/Idioma-Portugu%C3%Aas-green.svg)](./README_PT.md)
[![Idioma: Español](https://img.shields.io/badge/Idioma-Espa%C3%B1ol-yellow.svg)](./README_ES.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](./LICENSE)

An open-source, production-ready boilerplate designed to dramatically accelerate the setup, deployment, and infrastructure provisioning of new client MVPs on any VPS (DigitalOcean, Hetzner, AWS EC2).

---

## 🎯 Workflow Overview

1. **Clone Repository:**
   ```bash
   git clone https://github.com/user/vps-deploy-customizado.git
   cd vps-deploy-customizado
   ```
2. **Master DevOps CLI & Environment Setup:**
   ```bash
   npm run devops
   # or npm run setup
   ```
   *Launches the unified master CLI (`setup/devops.sh`) for selective service deployment, database backups, key generation, and VPS security hardening.*

3. **Execution Modes:**
   * **Unified DevOps Master Management CLI:**
     ```bash
     bash setup/devops.sh
     ```
     *Consolidates interactive service deployment, real-time logs, backup/restore routines, Docker system cleanup, and UFW firewall hardening into a single CLI.*
   * **Development Mode (Local):**
     ```bash
     npm run dev:infra
     ```
     *Spins up selected services with exposed ports on `localhost` via Docker Compose for easy debugging.*
   * **Production Mode (VPS Hardened):**
     ```bash
     bash setup/devops.sh deploy
     ```
     *Initializes Docker Swarm, applies UFW/Fail2ban hardening rules, and issues automatic Let's Encrypt SSL certificates via Traefik.*

---

## 🛠️ Infrastructure Services Stack

* **Reverse Proxy & SSL:** Traefik v2 (Automatic HTTP to HTTPS redirect + Let's Encrypt ACME resolver)
* **Container Management:** Portainer CE
* **CI/CD Pipeline:** Jenkins LTS (Internal local image builds without requiring external Docker Registries)
* **Databases & Caching:** MongoDB, Redis, Postvector (PostgreSQL 16 + `pgvector`), PostgreSQL Standard (Unmodified Postgres 16)
* **Messaging & Object Storage:** RabbitMQ (with Management Plugin), MinIO (S3-compatible)
* **Workflow Automation & CRM:** n8n (connected to Postgres Standard), Evogo (Evolution API Go), Evoccrm (Evolution CRM)
* **QA & Test Automation:** Headless Chromium service (Remote Debugging Port `9222`)

---

## 📱 Application Stack

* **Backend Core:** NestJS REST API
* **Microservices:** NestJS Payment Service
* **Frontend:** Vite + React + TypeScript PWA (**Mobile-First** & **Offline-First** with background data sync)
* **QA Automation:** Playwright E2E pipeline consuming headless Chromium

---

## 📚 Navigable Documentation Hub (GitHub Ready)

Explore detailed documentation categorized by area and context:

* 💡 **[100 High-Demand Industry Niche Solutions](./docs/niches/niche-solutions.md)** — Blueprints & BaaS workflows (Asaas / Stripe / Split Payments) across 100 commercial verticals.
* 🌐 **[Architecture & Traefik Routing](./docs/infrastructure/architecture.md)** — Ports, Traefik routes, DEV vs PROD mode.
* 🔒 **[Security & VPS Hardening](./docs/infrastructure/security-passwords.md)** — UFW, Fail2ban, and `.env` UUID backup policy.
* 🏗️ **[CI/CD & Jenkins Pipeline](./docs/cicd/jenkins-guide.md)** — Injected `.env` workflows and automatic Docker image pruning.
* 📱 **[Applications Overview (`/apps`)](./docs/applications/overview.md)** — NestJS APIs, Vite PWA, and QA automation setup.
* 📶 **[PWA Offline-First Architecture](./docs/applications/pwa-offline-first.md)** — Offline caching strategies and background sync.
* 🧪 **[QA Automation & Chromium](./docs/applications/qa-automation.md)** — Playwright E2E pipeline consuming headless Chromium.
* 🧠 **[ADR 0001: Docker Swarm over Kubernetes](./docs/adr/0001-why-docker-swarm-over-k8s.md)** — Cost vs complexity trade-offs.

---

## 📄 License
Distributed under the MIT License.
