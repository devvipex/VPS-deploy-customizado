# 🧪 Area: Applications — QA Automation & Chromium Integration

[← Back to Documentation Hub](../README.md)

---

## 🎯 Headless Chromium Integration

The infrastructure stack runs a containerized **Headless Chromium** instance via the `chromium-automation` service on port **`9222`**.

---

## ⚙️ Playwright Configuration

The E2E test suite in `apps/qa-test-automation-pipeline/playwright.config.ts` reads the `CHROMIUM_EXECUTABLE_PATH` environment variable:

```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:5173',
    launchOptions: {
      executablePath: process.env.CHROMIUM_EXECUTABLE_PATH || '/usr/bin/chromium-browser',
      args: ['--no-sandbox', '--disable-setuid-sandbox']
    }
  }
});
```

---

## 🚀 Running E2E Tests

```bash
cd apps/qa-test-automation-pipeline
npm test
```
