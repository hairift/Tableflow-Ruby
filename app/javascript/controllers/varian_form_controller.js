import { Controller } from "@hotwired/stimulus"

// Menambah dan menghapus grup varian pada form produk tanpa memuat ulang halaman.
export default class extends Controller {
  static targets = ["daftar", "cetakan", "grup", "hapus"]

  tambah() {
    const indeks = Date.now().toString()
    const html = this.cetakanTarget.innerHTML.replaceAll("BARIS", indeks)
    this.daftarTarget.insertAdjacentHTML("beforeend", html)
  }

  hapus(event) {
    const grup = event.currentTarget.closest('[data-varian-form-target="grup"]')
    if (!grup) return
    const penanda = grup.querySelector('[data-varian-form-target="hapus"]')
    if (penanda) penanda.value = "1"
    grup.classList.add("hidden")
  }
}
