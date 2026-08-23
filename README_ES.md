# 🚀 VPS Deploy Personalizado & Base MVP Stack

[![Language: English](https://img.shields.io/badge/Language-English-blue.svg)](./readme.md)
[![Idioma: Português](https://img.shields.io/badge/Idioma-Portugu%C3%Aas-green.svg)](./README_PT.md)
[![Idioma: Español](https://img.shields.io/badge/Idioma-Espa%C3%B1ol-yellow.svg)](./README_ES.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](./LICENSE)

Un boilerplate open-source listo para producción diseñado para acelerar drásticamente la configuración, despliegue y aprovisionamiento de infraestructura de nuevos MVPs en cualquier VPS (DigitalOcean, Hetzner, AWS EC2).

---

## 🎯 Flujo de Trabajo

1. **Clonar el Repositorio:**
   ```bash
   git clone https://github.com/user/vps-deploy-customizado.git
   cd vps-deploy-customizado
   ```
2. **CLI Maestra DevOps y Configuración de Entorno:**
   ```bash
   npm run devops
   # o npm run setup
   ```
   *Inicia la central única de control (`setup/devops.sh`) para despliegue selectivo de servicios, respaldos automáticos, generación de claves seguras y hardening de seguridad de la VPS.*

3. **Modos de Ejecución:**
   * **Central Maestra de Gestión DevOps:**
     ```bash
     bash setup/devops.sh
     ```
     *Consolida en una única CLI el despliegue selectivo, logs en vivo, rutinas de respaldo y restauración, limpieza de Docker y reglas de firewall UFW.*
   * **Desarrollo (Local):**
     ```bash
     npm run dev:infra
     ```
     *Levanta los servicios seleccionados con puertos expuestos en `localhost` mediante Docker Compose para depuración sencilla.*
   * **Producción (VPS Segura / Hardened):**
     ```bash
     bash setup/devops.sh deploy
     ```
     *Aplica reglas de firewall UFW y Fail2ban, inicializa Docker Swarm y emite certificados SSL automáticos de Let's Encrypt mediante Traefik.*

---

## 🛠️ Infraestructura y Servicios Base

* **Proxy Inverso y SSL:** Traefik v2 (Redirección automática de HTTP a HTTPS + resolver Let's Encrypt ACME)
* **Gestión de Contenedores:** Portainer CE
* **Pipeline de CI/CD:** Jenkins LTS (Compilación local de imágenes sin requerir Docker Registry externo)
* **Bases de Datos y Caché:** MongoDB, Redis, Postvector (PostgreSQL 16 + `pgvector`) y PostgreSQL Estándar (Postgres 16 oficial)
* **Mensajería y Almacenamiento S3:** RabbitMQ (con Plugin de Gestión), MinIO (Compatible con S3)
* **Automatización y CRM:** n8n (conectado a Postgres Estándar), Evogo (Evolution API Go) y Evoccrm (Evolution CRM)
* **Automatización de QA:** Contenedor Chromium Headless (Puerto de depuración remota `9222`)

---

## 📚 Centro de Documentación Navegable (Navegación GitHub)

Acceda a la documentación detallada por áreas directamente en GitHub:

* 💡 **[Guía de 100 Nichos Digitales e Integración BaaS](./docs/niches/niche-solutions_ES.md)** — Mapeo de 100 sectores, automatizaciones n8n y modelos de cobro (Split, Escrow, Suscripción).
* 🌐 **[Arquitectura y Enrutamiento Traefik](./docs/infrastructure/architecture.md)** — Puertos, rutas Traefik, modo DEV vs PROD.
* 🔒 **[Seguridad y Hardening de la VPS](./docs/infrastructure/security-passwords.md)** — Firewall UFW, Fail2ban y respaldos `.env`.
* 🏗️ **[Guía de CI/CD y Jenkins](./docs/cicd/jenkins-guide.md)** — Inyección de `.env` por proyecto y limpieza automática de imágenes Docker.
* 📱 **[Visión General de Aplicaciones (`/apps`)](./docs/applications/overview.md)** — APIs NestJS, Frontend Vite PWA y automatización de QA.
* 📶 **[Arquitectura PWA Offline-First](./docs/applications/pwa-offline-first.md)** — Caché offline y sincronización en segundo plano.
* 🧪 **[Automatización de QA y Chromium](./docs/applications/qa-automation.md)** — Suite de pruebas E2E con Playwright.
* 🧠 **[ADR 0001: Docker Swarm vs Kubernetes](./docs/adr/0001-why-docker-swarm-over-k8s.md)** — Análisis de costes vs complejidad operacional.
