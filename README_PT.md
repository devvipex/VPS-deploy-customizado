# 🚀 VPS Deploy Customizado & Base MVP Stack

[![Language: English](https://img.shields.io/badge/Language-English-blue.svg)](./readme.md)
[![Idioma: Português](https://img.shields.io/badge/Idioma-Portugu%C3%Aas-green.svg)](./README_PT.md)
[![Idioma: Español](https://img.shields.io/badge/Idioma-Espa%C3%B1ol-yellow.svg)](./README_ES.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](./LICENSE)

Um boilerplate open-source pronto para produção projetado para acelerar drasticamente a inicialização, deploy e provisionamento de infraestrutura de novos MVPs de clientes em qualquer VPS (DigitalOcean, Hetzner, AWS EC2).

---

## 🎯 O Fluxo de Trabalho

1. **Clone do Repositório:**
   ```bash
   git clone https://github.com/user/vps-deploy-customizado.git
   cd vps-deploy-customizado
   ```
2. **CLI Mestre DevOps & Setup de Ambiente:**
   ```bash
   npm run devops
   # ou npm run setup
   ```
   *Inicia a central única de controle (`setup/devops.sh`) para deploy seletivo de serviços, backups automáticos de bancos, geração de chaves seguras e hardening de segurança da VPS.*

3. **Modos de Execução:**
   * **Central Mestre de Gestão DevOps:**
     ```bash
     bash setup/devops.sh
     ```
     *Consolida em uma única CLI o deploy seletivo, logs ao vivo, rotinas de backup e restauração, limpeza do Docker e regras de firewall UFW.*
   * **Desenvolvimento (Local):**
     ```bash
     npm run dev:infra
     ```
     *Sobe os serviços selecionados com portas expostas no `localhost` via Docker Compose para fácil depuração.*
   * **Produção (VPS Segura / Hardened):**
     ```bash
     bash setup/devops.sh deploy
     ```
     *Aplica regras de firewall UFW e Fail2ban, inicializa o Docker Swarm e emite certificados SSL automáticos do Let's Encrypt via Traefik.*

---

## 🛠️ Infraestrutura e Base de Serviços

* **Proxy Reverso & SSL:** Traefik v2 (Redirecionamento automático HTTP para HTTPS + resolver Let's Encrypt ACME)
* **Gestão de Containers:** Portainer CE
* **Pipeline de CI/CD:** Jenkins LTS (Builds locais de imagens sem depender de Docker Registry externo)
* **Bancos de Dados & Cache:** MongoDB, Redis, Postvector (PostgreSQL 16 + `pgvector`) e PostgreSQL Padrão (Postgres 16 oficial)
* **Mensageria & Armazenamento S3:** RabbitMQ (com Plugin de Gestão), MinIO (Compatível com S3)
* **Automação & CRM:** n8n (conectado ao Postgres Padrão), Evogo (Evolution API Go) e Evoccrm (Evolution CRM)
* **Automação de QA:** Container Chromium Headless (Porta de Remote Debugging `9222`)

---

## 📚 Central de Documentação Navegável (GitHub Ready)

Acesse a documentação detalhada por áreas diretamente no GitHub:

* 💡 **[Guia dos 100 Nichos Digitais & Integrações BaaS](./docs/niches/niche-solutions_PT.md)** — Mapeamento de 100 setores, automações n8n e arquiteturas de cobrança (Split, Escrow, PIX).
* 🌐 **[Arquitetura & Roteamento Traefik](./docs/infrastructure/architecture.md)** — Portas, rotas Traefik, modo DEV vs PROD.
* 🔒 **[Segurança & Hardening da VPS](./docs/infrastructure/security-passwords.md)** — Firewall UFW, Fail2ban e backups de `.env`.
* 🏗️ **[Guia de CI/CD & Jenkins](./docs/cicd/jenkins-guide.md)** — Injeção de `.env` por projeto e limpeza automática de imagens Docker.
* 📱 **[Visão Geral das Aplicações (`/apps`)](./docs/applications/overview.md)** — APIs NestJS, Frontend Vite PWA e suíte de QA.
* 📶 **[Arquitetura PWA Offline-First](./docs/applications/pwa-offline-first.md)** — Cache offline e sincronização em segundo plano.
* 🧪 **[Automação de QA & Chromium](./docs/applications/qa-automation.md)** — Pipeline de testes E2E com Playwright.
* 🧠 **[ADR 0001: Docker Swarm vs Kubernetes](./docs/adr/0001-why-docker-swarm-over-k8s.md)** — Análise de custo vs complexidade operacional.
