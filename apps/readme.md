# 📱 Lista de Aplicações e Serviços (`/apps`)

Este diretório contém os projetos e microserviços que serão executados na infraestrutura do cliente.

---

## 1. ⚙️ `api-nestjs/`
* **Descrição:** API Backend principal do sistema.
* **Tecnologia:** NestJS + TypeScript.
* **Responsabilidade:** Regras de negócio principais, autenticação, conexão com MongoDB, Redis, RabbitMQ e Postvector.
* **Porta Interna:** `3000`

---

## 2. 💳 `api-nestjs-payment-service/`
* **Descrição:** Microserviço dedicado ao processamento de pagamentos.
* **Tecnologia:** NestJS + TypeScript.
* **Responsabilidade:** Integrações com gateways de pagamento (ex: Stripe, Mercado Pago, Asaas), webhooks e faturamento. Isolado por razões de segurança e resiliência.
* **Porta Interna:** `3001`

---

## 3. 🌐 `web-vite/`
* **Descrição:** Aplicação Frontend Web & PWA.
* **Tecnologia:** React + Vite + TypeScript.
* **Responsabilidade:** Interface do usuário desenvolvida com abordagem **Mobile-First** e suporte **Offline-First** (com Service Workers e sincronização automática ao reestabelecer conexão).
* **Porta Interna:** `80` / `5173`

---

## 4. 🧪 `qa-test-automation-pipeline/`
* **Descrição:** Projeto de automação de testes E2E e QA.
* **Tecnologia:** Playwright / Puppeteer.
* **Responsabilidade:** Testes de regressão e automações de navegador consumindo o Chromium configurado na VPS.
* **Integração:** Executado de forma headless via Jenkins nas entregas contínuas.