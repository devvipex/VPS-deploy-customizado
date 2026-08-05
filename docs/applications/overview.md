# 📱 Area: Applications — `/apps` Directory Overview

[← Back to Documentation Hub](../README.md)

---

## 💻 Project Structure Overview

The `/apps` directory functions as a modular multi-app architecture:

```text
apps/
├── api-nestjs/                  # Core NestJS REST API
├── api-nestjs-payment-service/  # Payment Processing Microservice
├── web-vite/                    # Mobile-First & Offline-First Vite PWA
└── qa-test-automation-pipeline/ # Playwright E2E Test Suite
```

---

## 🛠️ Component Breakdown

1. **`api-nestjs/`**:
   - Built on **NestJS & TypeScript**.
   - Connected to MongoDB, Redis, RabbitMQ, and Postvector (PGVector).

2. **`api-nestjs-payment-service/`**:
   - Isolated microservice for payment gateways (Stripe, Mercado Pago, Asaas).
   - Separated for resilience and independent scalability.

3. **`web-vite/`**:
   - Frontend built with **React + Vite + TypeScript**.
   - Built with a **Mobile-First** UI and **Offline-First** architecture (Service Worker & background sync).

4. **`qa-test-automation-pipeline/`**:
   - E2E testing suite with **Playwright**.
   - Connects to the **Headless Chromium** container service (Port `9222`).
