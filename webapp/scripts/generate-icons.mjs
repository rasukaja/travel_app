// Renders the Waypoint app icon to PNGs at the sizes a PWA / iOS
// home-screen icon needs, using the pre-installed Chromium via
// playwright-core (no network access required).
import { chromium } from 'playwright-core';
import { mkdirSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const outDir = path.join(__dirname, '..', 'public');
mkdirSync(outDir, { recursive: true });

// `scale` shrinks the foreground artwork so it stays inside the safe zone
// required for Android "maskable" icons (~80% of the canvas), while the
// background gradient always fills the full 512x512 canvas edge-to-edge.
function svgIcon(scale = 1) {
  return `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#38b6ff"/>
      <stop offset="1" stop-color="#0a56ff"/>
    </linearGradient>
  </defs>
  <rect width="512" height="512" fill="url(#bg)"/>
  <g transform="translate(256 256) scale(${scale}) translate(-256 -256)">
    <path d="M120 340 C 200 260, 240 300, 300 230 S 420 150, 420 150"
          fill="none" stroke="rgba(255,255,255,0.55)" stroke-width="14"
          stroke-linecap="round" stroke-dasharray="2 28"/>
    <circle cx="120" cy="340" r="16" fill="#ffffff"/>
    <g transform="translate(256 210)">
      <path d="M0 -100 C 62 -100 104 -55 104 -2 C 104 66 40 118 6 158
               C 2 163 -2 163 -6 158 C -40 118 -104 66 -104 -2
               C -104 -55 -62 -100 0 -100 Z"
            fill="#ffffff"/>
      <circle cx="0" cy="-4" r="42" fill="#0a56ff"/>
    </g>
  </g>
</svg>`.trim();
}

function htmlFor(svg, px) {
  return `<!doctype html><html><head><meta charset="utf-8"><style>
    html,body{margin:0;padding:0}
  </style></head><body>${svg.replace('<svg ', `<svg width="${px}" height="${px}" `)}</body></html>`;
}

const targets = [
  { file: 'pwa-192x192.png', size: 192, scale: 1 },
  { file: 'pwa-512x512.png', size: 512, scale: 1 },
  { file: 'apple-touch-icon.png', size: 180, scale: 1 },
  { file: 'maskable-icon-512x512.png', size: 512, scale: 0.72 },
];

const browser = await chromium.launch({
  executablePath: process.env.PW_CHROMIUM || '/opt/pw-browsers/chromium-1194/chrome-linux/chrome',
});
const page = await browser.newPage();

for (const { file, size, scale } of targets) {
  await page.setViewportSize({ width: size, height: size });
  await page.setContent(htmlFor(svgIcon(scale), size), { waitUntil: 'load' });
  const buf = await page.screenshot({ omitBackground: false });
  writeFileSync(path.join(outDir, file), buf);
  console.log('wrote', file, `${size}x${size}`);
}

writeFileSync(path.join(outDir, 'favicon.svg'), svgIcon(1) + '\n');
console.log('wrote favicon.svg');

await browser.close();
