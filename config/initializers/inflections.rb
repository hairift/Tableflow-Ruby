# Nama sumber daya bahasa Indonesia tidak berubah bentuk pada bentuk jamak.
# Aturan ini menyamakan infleksi model dengan infleksi rute berbahasa Indonesia.
ActiveSupport::Inflector.inflections do |inflect|
  inflect.uncountable %w[
    pesanan meja kategori produk panggilan_staf reservasi pelanggan
    tingkat_loyalitas shift pengguna laporan kunci_api webhook
    pembayaran item_pesanan log_status_pesanan
  ]
end
