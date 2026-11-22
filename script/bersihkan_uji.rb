# Hapus pesanan yang dibuat saat pengujian agar data demo tetap bersih.
uji = Pesanan.where("catatan LIKE ? OR catatan LIKE ?", "%uji%", "%smoke test%")
puts "Pesanan uji ditemukan: #{uji.count}"
uji.find_each do |pesanan|
  Tableflow::PengelolaPesanan.kembalikan_stok(pesanan) unless pesanan.dibatalkan?
  pesanan.destroy!
end
Meja.where.not(mulai_kunjungan_pada: nil).update_all(mulai_kunjungan_pada: nil, tagihan_terbuka: false)
puts "Sisa pesanan: #{Pesanan.count}"
