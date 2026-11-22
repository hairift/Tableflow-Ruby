# Informasi pesanan untuk sistem pembukuan eksternal (baca saja).
module Eksternal
  class PesananController < BaseController
    def index
      relasi = Pesanan.includes(:meja, item_pesanan: :produk).terbaru.limit(100)
      relasi = relasi.where(status: params[:status]) if params[:status].presence_in(Pesanan::STATUS)
      render json: relasi.map { |pesanan|
        {
          kode_pesanan: pesanan.kode_pesanan,
          nomor_meja: pesanan.meja&.nomor_meja,
          status: pesanan.status,
          metode: pesanan.metode,
          total_harga: pesanan.total_harga.to_i,
          dibuat_pada: pesanan.created_at,
          item: pesanan.item_pesanan.map { |item|
            { nama: item.produk.nama, jumlah: item.jumlah, harga_satuan: item.harga_saat_pesan.to_i }
          }
        }
      }
    end
  end
end
