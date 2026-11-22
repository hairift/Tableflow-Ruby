# Pratinjau total keranjang dihitung ulang sepenuhnya di sisi server.
module Publik
  class KeranjangController < ApplicationController
    def total
      item = params[:item]
      return gagal("Format keranjang tidak valid.") unless item.is_a?(Array)

      daftar = item.map do |b|
        {
          produk_id: b[:produk_id] || b["produk_id"],
          jumlah: b[:jumlah] || b["jumlah"],
          opsi_varian_ids: b[:opsi_varian_ids] || b["opsi_varian_ids"] || [],
          catatan: b[:catatan] || b["catatan"]
        }
      end

      hitungan = Tableflow::KalkulatorTotal.hitung(
        item_list: daftar,
        telepon_pelanggan: params[:telepon_pelanggan]
      )
      render json: {
        subtotal: hitungan[:subtotal].to_i,
        jumlah_diskon: hitungan[:jumlah_diskon].to_i,
        jumlah_pajak: hitungan[:jumlah_pajak].to_i,
        jumlah_biaya_layanan: hitungan[:jumlah_biaya_layanan].to_i,
        total_harga: hitungan[:total_harga].to_i,
        poin_diperoleh: hitungan[:poin_diperoleh]
      }
    end
  end
end
