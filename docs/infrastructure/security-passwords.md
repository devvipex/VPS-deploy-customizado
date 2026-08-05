# 🔒 Area: Infrastructure & DevOps — Security & Backup Policy

[← Back to Documentation Hub](../README.md)

---

## 🔑 Automated Password Generation (`manage-env.js`)

To eliminate hardcoded credentials or manual secret configuration, the repository utilizes **`setup/scripts/manage-env.js`**.

### 🎯 How Password Generation Works

When executing:
```bash
npm run setup
```

1. **Secret Key Detection:** Scans `.env` for key patterns containing:
   * `PASSWORD`, `PASS`, `SECRET`, `KEY`, `TOKEN`, `AUTH`
2. **Cryptographic Random Generation:** Empty secret values are populated with 24–32 character cryptographically secure strings (`crypto.randomBytes()`).
3. **Local Persistence:** Newly generated credentials are saved into the local `.env` file on the VPS.

---

## 📦 Automated Backup Policy

To guarantee existing credentials are never overwritten or lost during setup or update routines, a strict backup policy is enforced:

```text
setup/backups/env_bkp_<FILE_NAME>_YYYY-MM-DD_UUID.env
```

### ⚡ Backup Rules:
- **Trigger:** Whenever `.env` exists and contains pre-populated secrets prior to an edit.
- **Naming Format:** Timestamped in ISO format (`YYYY-MM-DD`) and an appended `UUID` separated by underscores (`_`).
- **Git Protection:** The `setup/backups/` directory and `.env` files are ignored in `.gitignore`, preventing accidental git leaks.
