# 📚 Documentation Hub & Navigation Index

Welcome to the **VPS Deploy & Base MVP Stack** documentation hub.

---

## 🗂️ Multilingual Support

* 🇺🇸 **[English Documentation (Default)](../readme.md)**
* 🇧🇷 **[Documentação em Português](../README_PT.md)**
* 🇪🇸 **[Documentación en Español](../README_ES.md)**

---

## 🧭 Navigation Index by Area & Context

### 1. 🌐 Infrastructure & DevOps (`docs/infrastructure/`)
* 📐 **[Architecture & Traefik Routing](./infrastructure/architecture.md)** — Traefik ingress, exposed DEV vs PROD ports, Let's Encrypt SSL.
* 🔒 **[Security & VPS Hardening](./infrastructure/security-passwords.md)** — Firewall rules (UFW), Fail2ban brute-force protection, and `.env` UUID backup policy.

### 2. 🏗️ CI/CD & Deployment (`docs/cicd/`)
* 🏗️ **[Jenkins Guide & Pipeline](./cicd/jenkins-guide.md)** — Setting up jobs, dynamic `.env` injection, and automatic Docker image pruning.

### 3. 📱 Applications & QA (`docs/applications/`)
* 📱 **[Applications Overview (`/apps`)](./applications/overview.md)** — NestJS APIs, Vite PWA, and QA automation setup.
* 📶 **[PWA Offline-First Architecture](./applications/pwa-offline-first.md)** — Offline caching strategies and background sync hooks.
* 🧪 **[QA Automation & Chromium](./applications/qa-automation.md)** — Playwright E2E pipeline consuming headless Chromium.

### 4. 🧠 Architecture Decision Records (`docs/adr/`)
* 📄 **[ADR 0001: Docker Swarm over Kubernetes](./adr/0001-why-docker-swarm-over-k8s.md)** — Architectural trade-offs on cost, complexity, and operational simplicity.
