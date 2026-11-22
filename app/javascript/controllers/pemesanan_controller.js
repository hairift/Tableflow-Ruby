import { Controller } from "@hotwired/stimulus"

// Mengelola keranjang, pemesanan, dan pantauan status di halaman pelanggan.
// Keranjang hanya menyimpan produk dan jumlah, bukan harga.
export default class extends Controller {
  static targets = [
    "dataMenu", "kartu", "totalBarang", "totalHarga", "drawerKeranjang",
    "daftarKeranjang", "totalKeranjang", "teleponMember", "metodeBayar",
    "panelVarian", "judulVarian", "isiVarian", "panelStatus", "kodeStatus",
    "labelStatus", "estimasiStatus", "isiStatus", "bagianBayar", "buktiInput",
    "panelPanggilan", "alasanPanggilan", "catatanPanggilan", "panelTagihan", "isiTagihan"
  ]

  connect() {
    this.produk = {}
    JSON.parse(this.dataMenuTarget.textContent).forEach((kategori) => {
      kategori.produk.forEach((produk) => {
        this.produk[produk.id] = { ...produk, kategori: kategori.nama, estimasi: kategori.estimasi }
      })
    })

    const kunci = `tableflow.keranjang.${this.data.get("token")}`
    this.kunciKeranjang = kunci
    this.keranjang = JSON.parse(localStorage.getItem(kunci) || "[]")
    this.varianSementara = null
    this.kodeAktif = null
    this.penghitungStatus = null
    this.giliranTotal = 0

    this.daftarKeranjangTarget.addEventListener("input", (event) => this.perbaruiCatatan(event))
    this.renderKeranjang()
    this.hitungTotal()
  }

  disconnect() {
    if (this.penghitungStatus) clearInterval(this.penghitungStatus)
  }

  // ---------- Kategori dan produk ----------

  pilihKategori(event) {
    const kategori = event.currentTarget.dataset.pemesananKategoriParam
    this.kartuTargets.forEach((kartu) => {
      kartu.classList.toggle("hidden", kartu.dataset.kategori !== kategori)
    })
    event.currentTarget.parentElement.querySelectorAll("button").forEach((tombol) => {
      const aktif = tombol === event.currentTarget
      tombol.classList.toggle("border-tinta", aktif)
      tombol.classList.toggle("bg-tinta", aktif)
      tombol.classList.toggle("text-krim", aktif)
      tombol.classList.toggle("border-garis", !aktif)
      tombol.classList.toggle("bg-white", !aktif)
      tombol.classList.toggle("text-tinta/60", !aktif)
    })
  }

  tambah(event) {
    const id = Number(event.currentTarget.dataset.pemesananProdukParam)
    const produk = this.produk[id]
    if (!produk) return

    if (produk.varian.length > 0) {
      this.bukaVarian(produk)
      return
    }
    this.tambahItem({
      produk_id: id, jumlah: 1, opsi_varian_ids: [], catatan: "",
      nama: produk.nama, varian: []
    })
  }

  bukaVarian(produk) {
    this.varianSementara = { produk, pilihan: {} }
    this.judulVarianTarget.textContent = produk.nama
    this.isiVarianTarget.innerHTML = produk.varian.map((grup) => `
      <div>
        <p class="mb-2 text-xs font-bold uppercase tracking-wide text-tinta/55">
          ${this.aman(grup.nama)}${grup.wajib ? ' <span class="text-terakota">wajib</span>' : ""}
        </p>
        <div class="space-y-1.5">
          ${grup.opsi.map((opsi) => `
            <label class="flex items-center justify-between rounded-lg border border-garis px-3 py-2.5 text-sm has-[:checked]:border-terakota has-[:checked]:bg-terakota/5">
              <span class="flex items-center gap-2">
                <input type="${grup.ganda ? "checkbox" : "radio"}" name="varian-${grup.id}"
                       data-varian-group="${grup.id}" value="${opsi.id}" class="accent-terakota">
                ${this.aman(opsi.nama)}
              </span>
              <span class="bilangan text-xs font-bold text-terakota">+ ${this.rupiah(opsi.tambahan)}</span>
            </label>
          `).join("")}
        </div>
      </div>
    `).join("")
    this.buka(this.panelVarianTarget)
  }

  simpanVarian() {
    if (!this.varianSementara) return
    const produk = this.varianSementara.produk
    const opsiIds = []
    const namaOpsi = []

    produk.varian.forEach((grup) => {
      const dipilih = Array.from(this.isiVarianTarget.querySelectorAll(`[data-varian-group="${grup.id}"]:checked`))
      if (grup.wajib && dipilih.length === 0) {
        alert(`Pilih minimal satu opsi untuk ${grup.nama}.`)
        return
      }
      dipilih.forEach((input) => {
        opsiIds.push(Number(input.value))
        const opsi = grup.opsi.find((item) => item.id === Number(input.value))
        if (opsi) namaOpsi.push(opsi.nama)
      })
    })
    if (produk.varian.some((grup) => grup.wajib && opsiIds.length === 0)) return

    this.tambahItem({
      produk_id: produk.id, jumlah: 1, opsi_varian_ids: opsiIds,
      catatan: "", nama: produk.nama, varian: namaOpsi
    })
    this.tutupVarian()
  }

  tutupVarian() {
    this.tutup(this.panelVarianTarget)
    this.varianSementara = null
  }

  // ---------- Keranjang ----------

  tambahItem(item) {
    const ada = this.keranjang.find((b) =>
      b.produk_id === item.produk_id &&
      b.opsi_varian_ids.join(",") === item.opsi_varian_ids.join(",")
    )
    if (ada) ada.jumlah += 1
    else this.keranjang.push(item)
    this.simpanKeranjang()
  }

  simpanKeranjang() {
    localStorage.setItem(this.kunciKeranjang, JSON.stringify(this.keranjang))
    this.renderKeranjang()
    this.hitungTotal()
  }

  renderKeranjang() {
    const jumlah = this.keranjang.reduce((total, b) => total + b.jumlah, 0)
    this.totalBarangTarget.textContent = jumlah

    if (this.keranjang.length === 0) {
      this.daftarKeranjangTarget.innerHTML = `
        <div class="rounded-xl border border-dashed border-garis px-4 py-10 text-center">
          <p class="text-sm font-bold text-tinta/60">Keranjang masih kosong</p>
          <p class="mt-1 text-xs text-tinta/45">Pilih menu yang tersedia di meja Anda.</p>
        </div>`
      return
    }

    this.daftarKeranjangTarget.innerHTML = this.keranjang.map((b, indeks) => `
      <div class="kartu-tipis p-4">
        <div class="flex items-start justify-between gap-3">
          <div class="min-w-0">
            <p class="text-sm font-bold">${this.aman(b.nama)}</p>
            ${b.varian.length ? `<p class="mt-0.5 text-[11px] text-tinta/50">${b.varian.map((v) => this.aman(v)).join(", ")}</p>` : ""}
          </div>
          <button type="button" data-action="pemesanan#hapusItem" data-indeks="${indeks}"
                  class="rounded-lg p-1.5 text-merah hover:bg-krim-2">${this.ikon("hapus", 16)}</button>
        </div>
        <div class="mt-3 flex items-center gap-3">
          <div class="flex items-center gap-2 rounded-lg border border-garis">
            <button type="button" data-action="pemesanan#kurangiJumlah" data-indeks="${indeks}" class="px-2.5 py-1.5">${this.ikon("kurang", 14)}</button>
            <span class="bilangan w-5 text-center text-sm font-bold">${b.jumlah}</span>
            <button type="button" data-action="pemesanan#tambahJumlah" data-indeks="${indeks}" class="px-2.5 py-1.5">${this.ikon("tambah", 14)}</button>
          </div>
          <input type="text" data-indeks="${indeks}" value="${this.aman(b.catatan || "")}"
                 placeholder="Catatan, misalnya tanpa es" class="kolom-form !py-1.5 !text-xs">
        </div>
      </div>
    `).join("")
  }

  perbaruiCatatan(event) {
    const indeks = event.target.dataset.indeks
    if (indeks === undefined) return
    this.keranjang[Number(indeks)].catatan = event.target.value
    localStorage.setItem(this.kunciKeranjang, JSON.stringify(this.keranjang))
  }

  tambahJumlah(event) {
    const indeks = Number(event.currentTarget.dataset.indeks)
    this.keranjang[indeks].jumlah += 1
    this.simpanKeranjang()
  }

  kurangiJumlah(event) {
    const indeks = Number(event.currentTarget.dataset.indeks)
    this.keranjang[indeks].jumlah -= 1
    if (this.keranjang[indeks].jumlah <= 0) this.keranjang.splice(indeks, 1)
    this.simpanKeranjang()
  }

  hapusItem(event) {
    this.keranjang.splice(Number(event.currentTarget.dataset.indeks), 1)
    this.simpanKeranjang()
  }

  async hitungTotal() {
    const giliran = ++this.giliranTotal
    try {
      const respon = await fetch("/api/publik/keranjang/total", {
        method: "POST",
        headers: { "Content-Type": "application/json", "X-CSRF-Token": this.data.get("csrf") },
        body: JSON.stringify({ item: this.keranjang, telepon_pelanggan: this.teleponMemberTarget.value })
      })
      const data = await respon.json()
      if (giliran !== this.giliranTotal) return
      this.totalHargaTarget.textContent = `Rp ${this.rupiah(data.total_harga || 0)}`
      this.totalKeranjangTarget.textContent = `Rp ${this.rupiah(data.total_harga || 0)}`
    } catch {
      if (giliran === this.giliranTotal) this.totalHargaTarget.textContent = "Rp 0"
    }
  }

  bukaKeranjang() {
    this.hitungTotal()
    this.buka(this.drawerKeranjangTarget)
  }

  tutupKeranjang() {
    this.tutup(this.drawerKeranjangTarget)
  }

  // ---------- Pemesanan dan status ----------

  async checkout() {
    if (this.keranjang.length === 0) {
      alert("Keranjang masih kosong.")
      return
    }
    const metode = this.metodeBayarTargets.find((input) => input.checked)?.value || "qris"
    const kunciIdempotensi = crypto.randomUUID()
    const respon = await this.permintaan("/api/publik/pesanan", {
      method: "POST",
      body: JSON.stringify({
        token: this.data.get("token"),
        metode,
        item: this.keranjang,
        telepon_pelanggan: this.teleponMemberTarget.value,
        kunci_idempotensi: kunciIdempotensi
      })
    })
    const data = await respon.json()
    if (!respon.ok) {
      alert(data.error || "Pesanan gagal dibuat.")
      return
    }

    this.keranjang = []
    localStorage.removeItem(this.kunciKeranjang)
    this.renderKeranjang()
    this.hitungTotal()
    this.tutupKeranjang()
    this.tampilkanStatus(data)
    this.kodeAktif = data.kode_pesanan
    if (this.penghitungStatus) clearInterval(this.penghitungStatus)
    this.penghitungStatus = setInterval(() => this.cekStatus(), 15000)
  }

  async cekStatus() {
    if (!this.kodeAktif) return
    const respon = await this.permintaan(`/api/publik/pesanan/${this.kodeAktif}`)
    const data = await respon.json()
    if (respon.ok) {
      this.tampilkanStatus(data)
      if (["selesai", "dibatalkan"].includes(data.status) && this.penghitungStatus) {
        clearInterval(this.penghitungStatus)
        this.penghitungStatus = null
      }
    }
  }

  tampilkanStatus(data) {
    this.kodeStatusTarget.textContent = data.kode_pesanan
    const ucapan = {
      menunggu: "Menunggu pembayaran",
      menunggu_verifikasi: "Menunggu verifikasi kasir",
      dikonfirmasi: "Pesanan dikonfirmasi",
      dimasak: "Sedang dimasak",
      siap: "Siap diambil",
      selesai: "Selesai",
      dibatalkan: "Dibatalkan"
    }
    this.labelStatusTarget.textContent = ucapan[data.status] || data.status
    this.estimasiStatusTarget.textContent = data.estimasi_menit ? `Estimasi dapur sekitar ${data.estimasi_menit} menit.` : ""
    this.isiStatusTarget.innerHTML = data.item.map((b) => `
      <div class="flex justify-between gap-3 border-b border-garis pb-2">
        <span>${this.aman(b.nama)} <span class="text-tinta/45">x${b.jumlah}</span></span>
        <span class="bilangan font-bold">${this.rupiah(b.harga_satuan * b.jumlah)}</span>
      </div>
    `).join("")
    this.bagianBayarTarget.classList.toggle("hidden", !(data.metode === "qris" && data.status === "menunggu"))
    this.buka(this.panelStatusTarget)
  }

  async unggahBukti() {
    if (!this.buktiInputTarget.files.length) {
      alert("Pilih berkas bukti pembayaran terlebih dahulu.")
      return
    }
    const bentuk = new FormData()
    bentuk.append("bukti", this.buktiInputTarget.files[0])
    const respon = await fetch(`/api/publik/pesanan/${this.kodeAktif}/bayar`, {
      method: "POST",
      headers: { "X-CSRF-Token": this.data.get("csrf"), "Accept": "application/json" },
      body: bentuk
    })
    const data = await respon.json()
    if (!respon.ok) {
      alert(data.error || "Bukti gagal diunggah.")
      return
    }
    this.tampilkanStatus(data)
  }

  tutupStatus() {
    this.tutup(this.panelStatusTarget)
  }

  // ---------- Layanan meja ----------

  bukaPanggilan() {
    this.buka(this.panelPanggilanTarget)
  }

  tutupPanggilan() {
    this.tutup(this.panelPanggilanTarget)
  }

  async kirimPanggilan() {
    const alasan = this.alasanPanggilanTargets.find((input) => input.checked)?.value || "air minum"
    await this.permintaan("/api/publik/panggilan-staf", {
      method: "POST",
      body: JSON.stringify({
        token: this.data.get("token"),
        alasan,
        catatan: this.catatanPanggilanTarget.value
      })
    })
    this.tutupPanggilan()
    alert("Panggilan terkirim. Petugas segera menuju meja Anda.")
  }

  async lihatTagihan() {
    this.isiTagihanTarget.textContent = "Memuat tagihan…"
    this.buka(this.panelTagihanTarget)
    const respon = await this.permintaan(`/api/publik/meja/${this.data.get("token")}/tagihan`)
    const data = await respon.json()
    if (!respon.ok) {
      this.isiTagihanTarget.textContent = data.error || "Tagihan tidak tersedia."
      return
    }
    this.isiTagihanTarget.innerHTML = `
      <p class="text-xs text-tinta/55">Meja ${this.aman(data.nomor_meja)} · ${data.jumlah_pesanan} pesanan</p>
      <p class="judul-display mt-2 text-3xl">Rp ${this.rupiah(data.total)}</p>
      <div class="mt-4 space-y-1 border-t border-garis pt-3">
        ${data.pesanan.map((p) => `<div class="flex justify-between text-xs"><span>${this.aman(p.kode)}</span><span>${this.aman(p.status)}</span></div>`).join("")}
      </div>`
  }

  tutupTagihan() {
    this.tutup(this.panelTagihanTarget)
  }

  // ---------- Pembantu ----------

  async permintaan(url, opsi = {}) {
    return fetch(url, {
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": this.data.get("csrf"),
        ...(opsi.headers || {})
      },
      ...opsi
    })
  }

  buka(elemen) {
    elemen.classList.remove("hidden")
    elemen.classList.add("flex")
  }

  tutup(elemen) {
    elemen.classList.add("hidden")
    elemen.classList.remove("flex")
  }

  rupiah(angka) {
    return Number(angka || 0).toLocaleString("id-ID")
  }

  aman(teks) {
    return String(teks ?? "").replace(/[&<>"']/g, (karakter) => ({
      "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;"
    })[karakter])
  }

  ikon(nama, ukuran) {
    const jalur = {
      hapus: '<path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>',
      kurang: '<path d="M5 12h14"/>',
      tambah: '<path d="M12 5v14M5 12h14"/>'
    }[nama] || ""
    return `<svg xmlns="http://www.w3.org/2000/svg" width="${ukuran}" height="${ukuran}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${jalur}</svg>`
  }
}
