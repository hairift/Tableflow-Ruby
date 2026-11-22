# Menghitung seluruh angka pesanan di sisi server.
# Klien hanya mengirim jumlah dan pilihan varian, tidak pernah mengirim harga.
module Tableflow
  module KalkulatorTotal
    RUPIAH_PER_POIN = 1000

    # item: { produk_id:, jumlah:, opsi_varian_ids: [], catatan: }
    def self.hitung(item_list:, telepon_pelanggan: nil, pengaturan: PengaturanToko.saat_ini)
      produk_by_id = Produk.where(id: item_list.map { |item| item[:produk_id] }).index_by(&:id)
      opsi_by_id = OpsiVarian.where(id: item_list.flat_map { |item| item[:opsi_varian_ids] || [] }).index_by(&:id)

      baris = item_list.map do |item|
        produk = produk_by_id[item[:produk_id].to_i]
        next nil if produk.blank? || !produk.tersedia?

        ids = Array(item[:opsi_varian_ids]).map(&:to_i)
        tambahan = ids.sum { |id| opsi_by_id[id]&.harga_tambahan.to_f }
        harga_satuan = produk.harga + tambahan
        jumlah = item[:jumlah].to_i
        next nil if jumlah <= 0

        {
          produk: produk,
          jumlah: jumlah,
          harga_satuan: harga_satuan,
          subtotal: harga_satuan * jumlah,
          catatan: item[:catatan],
          opsi_ids: ids
        }
      end.compact

      subtotal = baris.sum { |b| b[:subtotal] }
      diskon, alasan_diskon = diskon_member(telepon_pelanggan, subtotal)
      dasar_pajak = [subtotal - diskon, 0].max
      pajak = (dasar_pajak * pengaturan.persen_pajak / 100).round
      layanan = (dasar_pajak * pengaturan.persen_biaya_layanan / 100).round
      total = dasar_pajak + pajak + layanan

      {
        baris: baris,
        subtotal: subtotal,
        jumlah_diskon: diskon,
        alasan_diskon: alasan_diskon,
        jumlah_pajak: pajak,
        jumlah_biaya_layanan: layanan,
        total_harga: total,
        poin_diperoleh: (total / RUPIAH_PER_POIN).floor
      }
    end

    def self.diskon_member(telepon, subtotal)
      return [0, nil] if telepon.blank? || subtotal <= 0

      pelanggan = Pelanggan.find_by(telepon: telepon)
      return [0, nil] if pelanggan.blank?

      tingkat = TingkatLoyalitas.where("min_poin <= ?", pelanggan.poin).order(min_poin: :desc).first
      return [0, nil] if tingkat.blank?

      potongan = (subtotal * tingkat.persen_diskon / 100).round
      [potongan, "Member tingkat #{tingkat.min_poin} poin"]
    end
  end
end
