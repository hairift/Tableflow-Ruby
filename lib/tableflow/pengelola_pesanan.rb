# Konfirmasi pembayaran, perpindahan status, dan pembatalan pesanan.
module Tableflow
  class PengelolaPesanan
    class Gagal < StandardError; end

    def self.konfirmasi_bayar(pesanan:, petugas:, uang_diterima: nil, bukti_file: nil)
      pembayaran = pesanan.pembayaran
      raise Gagal, "Data pembayaran tidak ditemukan." if pembayaran.blank?
      raise Gagal, "Pesanan ini sudah diproses." unless pesanan.menunggu? || pesanan.menunggu_verifikasi?

      if pesanan.qris? && bukti_file.present?
        ubah_status(pesanan, "menunggu_verifikasi", petugas, "Bukti QRIS diterima")
        pembayaran.update!(bukti_file: bukti_file)
        return pesanan
      end

      status_baru = "dikonfirmasi"
      hasil = ubah_status(pesanan, status_baru, petugas, "Pembayaran dikonfirmasi")
      pembayaran.update!(
        diverifikasi_oleh: petugas,
        diverifikasi_pada: Time.current,
        uang_diterima: uang_diterima
      )
      tambah_poin(pesanan)
      hasil
    end

    # Verifikasi final oleh kasir setelah bukti QRIS diperiksa.
    def self.verifikasi_qris(pesanan:, petugas:)
      raise Gagal, "Pesanan bukan metode QRIS." unless pesanan.qris?
      raise Gagal, "Bukti pembayaran belum diunggah." if pesanan.pembayaran&.bukti_file.blank?

      hasil = ubah_status(pesanan, "dikonfirmasi", petugas, "Bukti QRIS terverifikasi")
      pesanan.pembayaran.update!(diverifikasi_oleh: petugas, diverifikasi_pada: Time.current)
      tambah_poin(pesanan)
      hasil
    end

    # Pembaruan status memakai kunci optimistis agar dua petugas tidak menimpa.
    def self.ubah_status(pesanan, status_baru, petugas, catatan = nil)
      status_lama = pesanan.status

      unless Tableflow::StatusPesanan.boleh_berpindah?(status_lama, status_baru)
        raise Gagal, "Perpindahan status tidak valid."
      end
      raise Gagal, "Sedang ada petugas lain yang memperbarui pesanan ini." unless Shift.berjalan.exists?

      berubah = Pesanan.where(id: pesanan.id, status: status_lama)
                       .update_all(status: status_baru, updated_at: Time.current)
      raise Gagal, "Status berubah oleh petugas lain. Muat ulang halaman." if berubah.zero?

      LogStatusPesanan.create!(
        pesanan: pesanan,
        status_dari: status_lama,
        status_ke: status_baru,
        diubah_oleh: petugas,
        catatan: catatan
      )
      pesanan.reload
      PengirimWebhook.kirim("pesanan.status_berubah", pesanan)
      pesanan
    end

    def self.batalkan(pesanan:, petugas:, alasan:, pin: nil, jumlah_pengembalian: 0)
      raise Gagal, "Pesanan tidak dapat dibatalkan." unless Tableflow::StatusPesanan.dapat_dibatalkan?(pesanan.status)

      if Tableflow::StatusPesanan.sudah_lunas?(pesanan.status)
        raise Gagal, "PIN petugas wajib diisi." if pin.blank?
        raise Gagal, "PIN tidak benar." unless petugas.cocok_pin?(pin)
      end

      status_lama = pesanan.status
      ActiveRecord::Base.transaction do
        pesanan.update!(
          status: "dibatalkan",
          jumlah_pengembalian: jumlah_pengembalian,
          catatan: [pesanan.catatan, alasan].compact.join(" | ")
        )
        kembalikan_stok(pesanan)
        kurangi_poin(pesanan)
        LogStatusPesanan.create!(
          pesanan: pesanan,
          status_dari: status_lama,
          status_ke: "dibatalkan",
          diubah_oleh: petugas,
          catatan: alasan
        )
      end
      PengirimWebhook.kirim("pesanan.status_berubah", pesanan.reload)
      pesanan
    end

    def self.tambah_poin(pesanan)
      return if pesanan.pelanggan.blank? || pesanan.poin_diperoleh <= 0

      pelanggan = Pelanggan.lock.find(pesanan.pelanggan_id)
      pelanggan.update!(poin: pelanggan.poin + pesanan.poin_diperoleh)
    end

    def self.kurangi_poin(pesanan)
      return if pesanan.pelanggan.blank? || pesanan.poin_diperoleh <= 0

      pelanggan = Pelanggan.lock.find(pesanan.pelanggan_id)
      pelanggan.update!(poin: [pelanggan.poin - pesanan.poin_diperoleh, 0].max)
    end

    def self.kembalikan_stok(pesanan)
      pesanan.item_pesanan.where(stok_dikurangi: true).find_each do |item|
        produk = Produk.lock.find(item.produk_id)
        produk.update!(stok: produk.stok + item.jumlah)
      end
    end
  end
end
