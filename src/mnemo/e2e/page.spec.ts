import { test, expect } from '@playwright/test';

test('index page exists', async ({ page }) => {
  await page.goto('localhost:4000');

  // create a locator
  const submitButton = page.locator('text=Submit Email');

  // Expect an attribute "to be strictly equal" to the value.
  await expect(submitButton).toHaveClass(/p-2/);
});
