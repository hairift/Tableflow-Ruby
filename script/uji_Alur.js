// Uji alur pemesanan pelanggan di browser sungguhan.
const { chromium } = require("playwright-core");

const DASAR = "http://127.0.0.1:3000";
const TOKEN = "e12c0c30b255eaa86c2074aa98b6b2fd5bc1966e0dba757e9557c9c5bd26ed75";

(async () => {
  const browser = await chromium.launch({
    executablePath: "C:/Program Files/Google/Chrome/Application/chrome.exe",
    headless: true,
    args: ["--no-sandbox", "--no-proxy-server", "--disable-gpu"]
  });
  const halaman = await browser.newPage({ viewport: { width: 1440, height: 950 } });
  const galat = [];
  halaman.on("pageerror", (e) => galat.push(e.message));

  await halaman.goto(`${DASAR}/t/${TOKEN}`, { waitUntil: "networkidle" });
  await halaman.locator('button:has-text("Tambah")').first().click();
  await halaman.waitForTimeout(300);

  // Pilih varian bila dialog varian muncul.
  if (await halaman.locator("[data-pemesanan-target='panelVarian']").isVisible()) {
    await halaman.locator("[data-pemesanan-target='isiVarian'] input").first().check();
    await halaman.locator('button:has-text("Tambah ke keranjang")').click();
  }
  await halaman.waitForTimeout(600);
  console.log("Total barang:", await halaman.locator("[data-pemesanan-target='totalBarang']").innerText());

  await halaman.locator('button:has-text("Lihat keranjang")').click();
  await halaman.waitForTimeout(500);
  const total = await halaman.locator("[data-pemesanan-target='totalKeranjang']").innerText();
  console.log("Total keranjang:", total);

  await halaman.locator('button:has-text("Pesan sekarang")').click();
  await halaman.waitForTimeout(1500);
  const kode = await halaman.locator("[data-pemesanan-target='kodeStatus']").innerText();
  const status = await halaman.locator("[data-pemesanan-target='labelStatus']").innerText();
  console.log("Kode pesanan:", kode);
  console.log("Status:", status);
  console.log("Galat JS:", galat.length ? galat.join(" | ") : "tidak ada");

  await halaman.screenshot({ path: "docs/screenshots/10-status-pesanan.png", fullPage: true });
  await browser.close();
  if (galat.length) process.exit(1);
})().catch((e) => {
  console.error("GAGAL:", e.message);
  process.exit(1);
});
