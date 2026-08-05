# 📚 Central de Documentação em Português

Seja bem-vindo à central de documentação da **Base VPS Deploy & MVP Multi-App**.

---

## 🧭 Índice por Área & Contexto

### 1. 💡 Soluções por Nicho & Integração com BaaS (`docs/niches/`)
* 🚀 **[Guia dos 100 Nichos Digitais & Integrações com Asaas/Stripe](./niches/niche-solutions_PT.md)** — Guia prático mapeando 100 nichos comerciais, dores de mercado, automações n8n e arquiteturas de cobrança (Split, Escrow, Recorrência, PIX).

### 2. 🌐 Infraestrutura & DevOps (`docs/infrastructure/`)
* 📐 **[Arquitetura Geral & Roteamento Traefik](./infrastructure/architecture.md)** — Roteamento Traefik, portas expostas em DEV vs PROD e SSL Let's Encrypt.
* 🔒 **[Segurança & Backup de Senhas](./infrastructure/security-passwords.md)** — Firewall UFW, proteção Fail2ban e política de backups de `.env` com UUID.

### 3. 🏗️ CI/CD & Deploy (`docs/cicd/`)
* 🏗️ **[Guia do Jenkins & Pipeline](./cicd/jenkins-guide.md)** — Configuração de jobs, injeção dinâmica de `.env` e remoção automática de imagens Docker órfãs.

### 4. 📱 Aplicações & QA (`docs/applications/`)
* 📱 **[Visão Geral dos Projetos (`/apps`)](./applications/overview.md)** — APIs NestJS, Frontend Vite PWA e automação de QA.
* 📶 **[Arquitetura PWA Offline-First](./applications/pwa-offline-first.md)** — Estratégias de cache offline e sincronização em segundo plano.
* 🧪 **[Automação de QA & Chromium](./applications/qa-automation.md)** — Suíte Playwright E2E consumindo o container Chromium.

### 5. 🧠 Decisão Arquitetural (`docs/adr/`)
* 📄 **[ADR 0001: Docker Swarm vs Kubernetes](./adr/0001-why-docker-swarm-over-k8s.md)** — Análise de custos e complexidade operacional.
