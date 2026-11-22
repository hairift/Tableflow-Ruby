# Menu publik dibaca saja dan tidak mengirim informasi harga modal atau stok.
module Publik
  class MenuController < ApplicationController
    def index
      kategori = Kategori.aktif.terurut.includes(produk: { grup_varian: :opsi_varian })
      render json: {
        kategori: kategori.map do |kat|
          {
            id: kat.id,
            nama: kat.nama,
            estimasi_menit: kat.estimasi_menit,
            produk: kat.produk.select(&:tersedia?).map do |produk|
              {
                id: produk.id,
                nama: produk.nama,
                harga: produk.harga,
                foto: produk.foto,
                grup_varian: produk.grup_varian.terurut.map do |grup|
                  {
                    id: grup.id,
                    nama: grup.nama,
                    wajib: grup.wajib,
                    ganda: grup.ganda,
                    opsi: grup.opsi_varian.terurut.map do |opsi|
                      { id: opsi.id, nama: opsi.nama, harga_tambahan: opsi.harga_tambahan }
                    end
                  }
                end
              }
            end
          }
        end
      }
    end
  end
end
