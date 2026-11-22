# Informasi toko dan berkas gambar yang dibutuhkan halaman pemesanan.
module Publik
  class PengaturanController < ApplicationController
    def index
      pengaturan = PengaturanToko.saat_ini
      render json: {
        nama_toko: pengaturan.nama_tampil,
        alamat: pengaturan.alamat,
        telepon: pengaturan.telepon,
        gambar_qris: pengaturan.gambar_qris,
        pajak_persen: pengaturan.persen_pajak,
        biaya_layanan_persen: pengaturan.persen_biaya_layanan
      }
    end

    def gambar_qris
      kirim_gambar(PengaturanToko.saat_ini.gambar_qris)
    end

    def foto_produk
      kirim_gambar(params[:nama])
    end

    private

    def kirim_gambar(nama)
      aman = aman_nama_berkas(nama)
      return head :not_found if aman.blank?

      path = Rails.root.join("public", "unggahan", aman)
      return head :not_found unless File.file?(path)

      send_file path, type: tipe_gambar(aman), disposition: :inline
    end

    def tipe_gambar(nama)
      case File.extname(nama).downcase
      when ".png" then "image/png"
      when ".webp" then "image/webp"
      else "image/jpeg"
      end
    end
  end
end
