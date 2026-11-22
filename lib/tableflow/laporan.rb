# Agregasi pendapatan, produk terlaris, dan estimasi margin.
module Tableflow
  module Laporan
    BATAS_HARI = 92

    def self.ringkasan(dari:, sampai:)
      dari_waktu = Tableflow::Waktu.awal_hari(dari)
      sampai_waktu = Tableflow::Waktu.akhir_hari(sampai)
      return { error: "Rentang tanggal maksimal #{BATAS_HARI} hari." } if sampai_waktu - dari_waktu > BATAS_HARI.days

      pesanan = Pesanan.pendapatan.where(created_at: dari_waktu..sampai_waktu)
      {
        dari: dari_waktu,
        sampai: sampai_waktu,
        jumlah_pesanan: pesanan.count,
        total_pendapatan: pesanan.sum(:total_harga),
        pendapatan_per_metode: pesanan.group(:metode).sum(:total_harga),
        produk_terlaris: produk_terlaris(dari_waktu, sampai_waktu),
        estimasi_margin: estimasi_margin(dari_waktu, sampai_waktu)
      }
    end

    def self.produk_terlaris(dari, sampai)
      ItemPesanan.joins(:pesanan)
                 .where(pesanan: { status: Tableflow::StatusPesanan::PENDAPATAN, created_at: dari..sampai })
                 .group("item_pesanan.produk_id")
                 .select("item_pesanan.produk_id, SUM(item_pesanan.jumlah) AS jumlah_terjual, " \
                         "SUM(item_pesanan.jumlah * item_pesanan.harga_saat_pesan) AS total")
                 .order(Arel.sql("jumlah_terjual DESC"))
                 .limit(10)
                 .map do |baris|
        {
          nama: Produk.find_by(id: baris.produk_id)&.nama || "Produk dihapus",
          jumlah: baris.jumlah_terjual,
          total: baris.total
        }
      end
    end

    # Margin hanya dihitung untuk produk yang memiliki harga modal.
    def self.estimasi_margin(dari, sampai)
      baris = ItemPesanan.joins(:pesanan, :produk)
                         .where(pesanan: { status: Tableflow::StatusPesanan::PENDAPATAN, created_at: dari..sampai })
                         .where.not(produk: { harga_modal: nil })
                         .select("item_pesanan.jumlah, item_pesanan.harga_saat_pesan, produk.harga_modal")
      pendapatan = baris.sum { |b| b.jumlah * b.harga_saat_pesan }
      modal = baris.sum { |b| b.jumlah * b.harga_modal }
      { pendapatan: pendapatan, modal: modal, laba: pendapatan - modal }
    end
  end
end
