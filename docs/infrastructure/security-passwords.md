# 🔒 Area: Infrastructure & DevOps — Security, Backup & Master CLI Policy

[← Back to Documentation Hub](../README.md)

---

## 🛠️ Master DevOps Management CLI (`setup/devops.sh`)

All infrastructure operations (service deployment, database backups, key generation, security hardening, real-time logs, and Docker cleanup) are consolidated into the master CLI tool **`setup/devops.sh`**:

```bash
npm run devops
# or
bash setup/devops.sh
```

---

## 🔑 Automated Password & Key Generation (`manage-env.js`)

To eliminate hardcoded credentials or manual secret configuration, the repository utilizes **`setup/scripts/manage-env.js`** (invoked automatically by `setup/devops.sh`).

### 🎯 How Password Generation Works

When executing `bash setup/devops.sh env` or `npm run setup`:

1. **Secret Key Detection:** Scans `.env` for key patterns containing:
   * `PASSWORD`, `PASS`, `SECRET`, `KEY`, `TOKEN`, `AUTH`
2. **Cryptographic Random Generation:** Empty secret values are populated with 24–32 character cryptographically secure strings (`crypto.randomBytes()`).
3. **Automatic Template Key Sync:** Appends newly introduced variables from `.env.example` to existing `.env` files automatically.
4. **Local Persistence:** Newly generated credentials are saved into the local `.env` file on the VPS.

---

## 📦 Automated & Interactive Backup Policy

To guarantee existing credentials and database records are never lost, a strict backup policy is enforced via `setup/devops.sh backup`:

```text
setup/backups/postvector_<TIMESTAMP>.sql
setup/backups/postgres_std_<TIMESTAMP>.sql
setup/backups/mongodb_<TIMESTAMP>.archive
setup/backups/redis_<TIMESTAMP>.rdb
setup/backups/env_<TIMESTAMP>.env
```

### ⚡ Backup Rules:
- **Trigger:** Interactive terminal menu (`bash setup/devops.sh backup`) or CLI arguments.
- **Scope:** Complete infrastructure dumps (Postvector, Postgres Standard, MongoDB, Redis, `.env`), selective per-database exports, guided restore, and automatic deletion of old backups (>30 days).
- **Git Protection:** The `setup/backups/` directory and `.env` files are ignored in `.gitignore`, preventing accidental git leaks.
