// Ambil screenshot nyata dari aplikasi yang berjalan memakai Chrome lokal.
const { chromium } = require("playwright-core");
const fs = require("fs");
const path = require("path");

const DASAR = "http://127.0.0.1:3000";
const KELUAR = path.resolve("docs/screenshots");
const TOKEN = "e12c0c30b255eaa86c2074aa98b6b2fd5bc1966e0dba757e9557c9c5bd26ed75";

fs.mkdirSync(KELUAR, { recursive: true });

(async () => {
  const browser = await chromium.launch({
    executablePath: "C:/Program Files/Google/Chrome/Application/chrome.exe",
    headless: true,
    args: ["--no-sandbox", "--no-proxy-server", "--disable-gpu"]
  });
  const konteks = await browser.newContext({ viewport: { width: 1440, height: 950 }, locale: "id-ID" });
  const halaman = await konteks.newPage();

  async function ambil(nama, url, penuh = true) {
    await halaman.goto(DASAR + url, { waitUntil: "networkidle" });
    await halaman.screenshot({ path: path.join(KELUAR, nama), fullPage: penuh });
    console.log(`OK ${nama} -> ${halaman.title()}`);
  }

  await ambil("01-beranda.png", "/");
  await ambil("02-pemesanan-meja.png", "/t/" + TOKEN);
  await ambil("03-masuk.png", "/masuk");

  // Login sebagai admin.
  await halaman.goto(DASAR + "/masuk", { waitUntil: "networkidle" });
  await halaman.fill('input[name="username"]', "admin");
  await halaman.fill('input[name="kata_sandi"]', "Tableflow2026!");
  await Promise.all([
    halaman.waitForURL("**/panel/dashboard"),
    halaman.locator('button[type="submit"]').first().click()
  ]);
  await halaman.screenshot({ path: path.join(KELUAR, "04-dashboard.png"), fullPage: true });
  console.log("OK 04-dashboard.png -> " + halaman.title());

  const halamanPanel = [
    ["05-pesanan.png", "/panel/pesanan"],
    ["06-meja.png", "/panel/meja"],
    ["07-produk.png", "/panel/produk"],
    ["08-laporan.png", "/panel/laporan"],
    ["09-shift.png", "/panel/shift"]
  ];
  for (const [nama, url] of halamanPanel) {
    await ambil(nama, url);
  }

  await browser.close();
  console.log("SELESAI");
})().catch((e) => {
  console.error("GAGAL:", e.message);
  process.exit(1);
});
