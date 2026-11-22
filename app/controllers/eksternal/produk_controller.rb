# Daftar menu untuk sistem inventory eksternal (baca saja).
module Eksternal
  class ProdukController < BaseController
    def index
      render json: Produk.includes(:kategori).order(:nama).map { |produk|
        {
          id: produk.id,
          nama: produk.nama,
          kategori: produk.kategori.nama,
          harga: produk.harga.to_i,
          stok: produk.stok,
          lacak_stok: produk.lacak_stok,
          tersedia: produk.tersedia
        }
      }
    end
  end
end
