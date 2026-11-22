// Kunjungi semua halaman admin setelah login dan laporkan bila ada error.
const { chromium } = require("playwright-core");

const DASAR = "http://127.0.0.1:3000";
const HALAMAN = [
  "/panel/dashboard", "/panel/pesanan", "/panel/pesanan/log-aktivitas", "/panel/pesanan/manual",
  "/panel/meja", "/panel/meja/new", "/panel/produk", "/panel/produk/new",
  "/panel/kategori", "/panel/kategori/new", "/panel/panggilan_staf", "/panel/reservasi",
  "/panel/reservasi/new", "/panel/pelanggan", "/panel/tingkat_loyalitas",
  "/panel/tingkat_loyalitas/new", "/panel/shift", "/panel/pengguna", "/panel/pengguna/new",
  "/panel/laporan", "/panel/pengaturan", "/panel/kunci_api",
  "/panel/webhook"
];

(async () => {
  const browser = await chromium.launch({
    executablePath: "C:/Program Files/Google/Chrome/Application/chrome.exe",
    headless: true,
    args: ["--no-sandbox", "--no-proxy-server", "--disable-gpu"]
  });
  const halaman = await browser.newPage();
  await halaman.goto(DASAR + "/masuk", { waitUntil: "networkidle" });
  await halaman.fill('input[name="username"]', "admin");
  await halaman.fill('input[name="kata_sandi"]', "Tableflow2026!");
  await Promise.all([
    halaman.waitForURL("**/panel/dashboard"),
    halaman.locator('button[type="submit"]').first().click()
  ]);

  let gagal = 0;
  for (const url of HALAMAN) {
    const respons = await halaman.goto(DASAR + url, { waitUntil: "domcontentloaded" });
    const tubuh = await halaman.locator("body").innerText();
    const rusak = respons.status() !== 200 || /NameError|NoMethodError|ActionView::Template|SyntaxError/.test(tubuh);
    console.log(`${rusak ? "GAGAL" : "OK   "} ${respons.status()} ${url}`);
    if (rusak) {
      gagal += 1;
      console.log("  " + tubuh.slice(0, 180).replace(/\n/g, " "));
    }
  }
  await browser.close();
  console.log(`Selesai. Gagal: ${gagal}`);
  if (gagal) process.exit(1);
})().catch((e) => { console.error("GAGAL:", e.message); process.exit(1); });
