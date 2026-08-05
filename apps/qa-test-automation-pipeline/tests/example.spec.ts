import { test, expect } from '@playwright/test';

test('Verifica se a aplicação PWA carrega e exibe status offline-first', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveTitle(/Vite/i);
  const banner = page.locator('.network-banner');
  await expect(banner).toBeVisible();
});
