# 📚 Centro de Documentación en Español

Bienvenido al centro de documentación de **VPS Deploy & Base MVP Stack**.

---

## 🧭 Índice por Área y Contexto

### 1. 💡 Soluciones por Nicho e Integración con BaaS (`docs/niches/`)
* 🚀 **[Guía de 100 Nichos Digitales e Integración con Stripe/Asaas](./niches/niche-solutions_ES.md)** — Guía detallada que mapea 100 nichos comerciales, automatizaciones n8n y modelos de cobro (Split, Escrow, Suscripción).

### 2. 🌐 Infraestructura y DevOps (`docs/infrastructure/`)
* 📐 **[Arquitectura General y Enrutamiento Traefik](./infrastructure/architecture.md)** — Enrutamiento Traefik, puertos expuestos en DEV vs PROD y SSL Let's Encrypt.
* 🔒 **[Seguridad y Respaldo de Contraseñas](./infrastructure/security-passwords.md)** — Firewall UFW, protección Fail2ban y política de respaldos `.env` con UUID.

### 3. 🏗️ CI/CD y Despliegue (`docs/cicd/`)
* 🏗️ **[Guía de Jenkins y Pipeline](./cicd/jenkins-guide.md)** — Configuración de trabajos, inyección dinámica de `.env` y eliminación automática de imágenes Docker huérfanas.

### 4. 📱 Aplicaciones y QA (`docs/applications/`)
* 📱 **[Visión General de Proyectos (`/apps`)](./applications/overview.md)** — APIs NestJS, Frontend Vite PWA y automatización de QA.
* 📶 **[Arquitectura PWA Offline-First](./applications/pwa-offline-first.md)** — Estrategias de caché offline y sincronización en segundo plano.
* 🧪 **[Automatización de QA y Chromium](./applications/qa-automation.md)** — Suite Playwright E2E consumiendo el contenedor Chromium.

### 5. 🧠 Decisión de Arquitectura (`docs/adr/`)
* 📄 **[ADR 0001: Docker Swarm vs Kubernetes](./adr/0001-why-docker-swarm-over-k8s.md)** — Análisis de costes y complejidad operacional.
