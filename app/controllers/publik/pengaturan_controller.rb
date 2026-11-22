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
        biaya_layanan_persen: pengaturan.biaya_layanan_persen
      }
    end

    def gambar_qris
      kirim_gambar(PengaturanToko.saat_ini.gambar_qris)
    end

    def foto_produk
      nama = nama_dari_rute

      [["gambar-produk", :aman_nama_statis], ["unggahan", :aman_nama_berkas]].each do |direktori, sanitasi|
        aman = send(sanitasi, nama)
        next if aman.blank?

        path = Rails.root.join("public", direktori, aman)
        next unless File.file?(path)

        return send_file path, type: tipe_gambar(aman), disposition: :inline
      end

      head :not_found
    end

    private

    # Rails memisahkan ekstensi dari parameter :nama menjadi params[:format].
    def nama_dari_rute
      [params[:nama], params[:format]].compact.join(".")
    end

    def kirim_gambar(nama)
      aman = aman_nama_berkas(nama)
      return head :not_found if aman.blank?

      path = Rails.root.join("public", "unggahan", aman)
      return head :not_found unless File.file?(path)

      send_file path, type: tipe_gambar(aman), disposition: :inline
    end

    # Nama berkas bawaan tidak memakai awalan hash seperti berkas unggahan.
    def aman_nama_statis(nama)
      aman = File.basename(nama.to_s)
      return nil unless aman.match?(/\A[a-z0-9-]+\.(png|jpg|jpeg|webp)\z/)

      aman
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
