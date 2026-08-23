# 🏗️ Area: CI/CD — Jenkins Guide & Dynamic `.env` Injection

[← Back to Documentation Hub](../README.md)

---

## 🎯 Why Use Jenkins in this Boilerplate?

Portainer CE does not support building Docker images directly from Git repositories via UI without configuring an external Docker Registry (such as Docker Hub or private GHCR).

**Jenkins** is included to streamline this pipeline: it builds Docker images locally on the VPS host and updates Docker Swarm services without external registry dependencies.

---

## 🔑 Dynamic `.env` Generation & Injection

Each client project maintains its environment configuration in `.env` (generated automatically from `.env.example`).

During the build pipeline execution, Jenkins runs:

```groovy
sh "node /opt/vps-deploy/setup/scripts/manage-env.js /opt/vps-deploy/.env /opt/vps-deploy/.env.example"
```

1. **Populates empty application secrets** (such as `JWT_SECRET`, `DB_PASSWORD`, `API_KEY`).
2. **Generates timestamped backups** if credentials already existed.
3. **Injects the generated `.env` file** into the build workspace prior to `docker build`.

---

## 🧹 Automated Docker Image Pruning (`docker image prune`)

To prevent recurring builds from exhausting VPS disk storage with orphan images (`dangling images`), the Jenkinsfile template enforces post-build cleanup:

```groovy
post {
    always {
        echo "🧹 Pruning unused Docker images..."
        sh "docker image prune -f --filter 'until=24h'"
    }
}
```

This guarantees intermediate build layers are automatically destroyed without impacting running containers.
