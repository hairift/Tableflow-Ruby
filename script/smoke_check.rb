# Pemeriksaan cepat logika inti setelah seed.
meja = Meja.first
raise "Tidak ada meja" if meja.nil?

token = meja.token_qr
terverifikasi = Tableflow::TokenMeja.verifikasi(token)
puts "Meja: #{meja.nomor_meja}"
puts "Token: #{token[0, 12]}..."
puts "Verifikasi token: #{terverifikasi&.nomor_meja}"
puts "Verifikasi token palsu: #{Tableflow::TokenMeja.verifikasi('tokenpalsu').inspect}"
puts "Kode pesanan: #{Tableflow::KodePesanan.buat}"
puts "Produk: #{Produk.count}, Kategori: #{Kategori.count}, Pengguna: #{Pengguna.count}, Meja: #{Meja.count}"
puts "Shift berjalan: #{Shift.berjalan.first&.id.inspect}"

# Uji kalkulator dengan satu produk (kunci simbol).
produk = Produk.first
hitungan = Tableflow::KalkulatorTotal.hitung(
  item_list: [{ produk_id: produk.id, jumlah: 2, opsi_varian_ids: [], catatan: "" }]
)
puts "Kalkulator subtotal: #{hitungan[:subtotal]}, total: #{hitungan[:total_harga]}, poin: #{hitungan[:poin_diperoleh]}"
raise "Kalkulator return total nol" unless hitungan[:total_harga].to_i > 0

# Uji pembuatan pesanan nyata + idempotensi.
kunci = SecureRandom.uuid
args = {
  meja: meja,
  item_list: [{ produk_id: produk.id, jumlah: 1, opsi_varian_ids: [], catatan: "uji" }],
  metode: "tunai",
  catatan: "smoke test",
  kunci_idempotensi: kunci
}
pesanan = Tableflow::PembuatPesanan.new(**args).panggil
lagi = Tableflow::PembuatPesanan.new(**args).panggil
puts "Pesanan dibuat: #{pesanan.kode_pesanan}, total: #{pesanan.total_harga.to_i}, status: #{pesanan.status}"
puts "Idempotensi: #{lagi.id == pesanan.id ? 'OK' : 'GAGAL'}"

# Uji konfirmasi pembayaran tunai.
petugas = Pengguna.find_by(peran: "kasir") || Pengguna.first
Tableflow::PengelolaPesanan.konfirmasi_bayar(pesanan: pesanan, petugas: petugas, uang_diterima: 20000)
puts "Setelah konfirmasi: #{pesanan.reload.status}"
puts "Kembalian: #{pesanan.pembayaran.kembalian.to_i}"

# Bersihkan data uji.
pesanan.destroy!
puts "SMOKE OK"
