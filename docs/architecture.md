# 📐 Guia de Arquitetura e Roteamento Traefik

Esta documentação descreve a infraestrutura configurada para os ambientes de **Desenvolvimento (DEV)** e **Produção (PROD/VPS)**.

---

## 💻 1. Como Subir em Desenvolvimento (DEV)

Para rodar localmente no computador do desenvolvedor sem depender de Docker Swarm ou certificados SSL do Let's Encrypt:

```bash
# 1. Gerar/Verificar o arquivo .env
npm run setup

# 2. Subir todos os serviços da infraestrutura localmente via Docker Compose
npm run dev:infra
```

### 🔌 Portas Expostas Diretas em DEV:
No ambiente DEV, as portas dos bancos e serviços ficam expostas diretamente no `localhost` para conectar ferramentas como DBeaver, MongoDB Compass ou Redis Insight:

* **MongoDB:** `localhost:27017`
* **Redis:** `localhost:6379`
* **Postvector (PostgreSQL):** `localhost:5432`
* **RabbitMQ Management:** `localhost:15672` (AMQP: `5672`)
* **MinIO Console:** `localhost:9001` (API: `9000`)
* **Jenkins:** `localhost:8080` (ou `http://jenkins.localhost`)
* **Portainer:** `localhost:9000` (ou `http://portainer.localhost`)
* **n8n:** `localhost:5678` (ou `http://n8n.localhost`)
* **Traefik Dashboard:** `localhost:8082`
* **Chromium (Headless E2E):** `localhost:9222`

Para encerrar os serviços em DEV:
```bash
npm run dev:infra:down
```

---

## 🚀 2. Como Subir em Produção (PROD / VPS)

Na VPS do cliente, a infraestrutura roda utilizando **Docker Swarm** e certificados **Let's Encrypt**:

```bash
# 1. Executar o setup inicial
./setup/init.sh

# 2. Deploy da Stack da Infraestrutura
npm run deploy:infra
```

### 🌐 Roteamento HTTPS via Traefik (Let's Encrypt)

* **Portainer:** `https://portainer.<DOMAIN_NAME>`
* **Jenkins:** `https://jenkins.<DOMAIN_NAME>`
* **n8n:** `https://n8n.<DOMAIN_NAME>`
* **API Principal (NestJS):** `https://api.<DOMAIN_NAME>`
* **Frontend Web (Vite PWA):** `https://<DOMAIN_NAME>`
