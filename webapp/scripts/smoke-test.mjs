import { chromium } from 'playwright-core';

const errors = [];
const browser = await chromium.launch({
  executablePath: process.env.PW_CHROMIUM || '/opt/pw-browsers/chromium-1194/chrome-linux/chrome',
});
const page = await browser.newPage();
page.on('pageerror', (e) => errors.push(`pageerror: ${e.message}`));
page.on('console', (msg) => {
  if (msg.type() === 'error') errors.push(`console.error: ${msg.text()}`);
});

await page.goto('http://localhost:4173/', { waitUntil: 'networkidle' });
await page.waitForSelector('text=Meine Reisen', { timeout: 5000 });

// Create a trip
await page.click('.fab');
await page.fill('input[placeholder="z.B. Sommerurlaub Italien"]', 'Testreise Rom');
await page.fill('input[placeholder="z.B. Rom, Italien"]', 'Rom, Italien');
await page.fill('input[type="date"] >> nth=0', '2026-09-01');
await page.fill('input[type="date"] >> nth=1', '2026-09-07');
await page.click('button:has-text("Speichern")');
await page.waitForSelector('text=Testreise Rom', { timeout: 5000 });
console.log('✓ trip created and listed');

// Open trip, add itinerary item
await page.click('text=Testreise Rom');
await page.waitForSelector('text=Zeitstrahl');
await page.click('.fab');
await page.fill('input[placeholder="z.B. LH 123 nach Rom"]', 'Flug nach Rom');
await page.click('button:has-text("Speichern")');
await page.waitForSelector('text=Flug nach Rom', { timeout: 5000 });
console.log('✓ itinerary item created');

// Packing tab
await page.click('button:has-text("Packliste")');
await page.fill('input[placeholder="Neuer Gegenstand..."]', 'Sonnenbrille');
await page.press('input[placeholder="Neuer Gegenstand..."]', 'Enter');
await page.waitForSelector('text=Sonnenbrille', { timeout: 5000 });
console.log('✓ packing item created');

// Map tab (should show empty state gracefully, no located items)
await page.click('button:has-text("Karte")');
await page.waitForSelector('text=Ort mit Koordinaten', { timeout: 5000 });
console.log('✓ map tab renders empty state without crashing');

await page.screenshot({ path: 'screenshot.png' });

await browser.close();

if (errors.length > 0) {
  console.error('Console/page errors detected:');
  for (const e of errors) console.error(' -', e);
  process.exit(1);
}
console.log('✓ no console/page errors');
