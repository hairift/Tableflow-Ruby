# Uji alur QRIS: pesanan, unggah bukti, verifikasi kasir.
meja = Meja.first
produk = Produk.first
petugas = Pengguna.find_by(peran: "kasir") || Pengguna.first

pesanan = Tableflow::PembuatPesanan.new(
  meja: meja,
  item_list: [{ produk_id: produk.id, jumlah: 1, opsi_varian_ids: [], catatan: "" }],
  metode: "qris",
  catatan: "uji qris"
).panggil
puts "Dibuat: #{pesanan.kode_pesanan} (#{pesanan.status})"

pesanan.pembayaran.update!(bukti_file: "bukti-uji.png")
pesanan.update!(status: "menunggu_verifikasi")
LogStatusPesanan.create!(pesanan: pesanan, status_dari: "menunggu",
                         status_ke: "menunggu_verifikasi", catatan: "uji")

Tableflow::PengelolaPesanan.verifikasi_qris(pesanan: pesanan, petugas: petugas)
puts "Terverifikasi: #{pesanan.reload.status}"

Tableflow::PengelolaPesanan.ubah_status(pesanan, "dimasak", petugas, "uji")
puts "Dimasak: #{pesanan.reload.status}"

# Batalkan dengan PIN admin yang benar.
admin = Pengguna.find_by!(username: "admin")
Tableflow::PengelolaPesanan.batalkan(pesanan: pesanan, petugas: admin,
                                     alasan: "uji", pin: "246810")
puts "Dibatalkan: #{pesanan.reload.status}"

pesanan.destroy!
puts "QRIS OK"
