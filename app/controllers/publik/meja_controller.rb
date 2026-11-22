# Pintu masuk pelanggan melalui token QR dan tagihan kunjungan berjalan.
module Publik
  class MejaController < ApplicationController
    def tampil
      @meja = Tableflow::TokenMeja.verifikasi(params[:token])
      return redirect_to root_path, alert: "Kode QR tidak valid atau meja tidak aktif." if @meja.blank?

      @kategori = Kategori.aktif.terurut.includes(produk: { grup_varian: :opsi_varian })
      @pengaturan = PengaturanToko.saat_ini
    end

    def tagihan
      meja = Tableflow::TokenMeja.verifikasi(params[:token])
      return gagal("Kode QR tidak valid.", status: :forbidden) if meja.blank?

      awal = meja.mulai_kunjungan_pada || 1.day.ago
      pesanan = meja.pesanan.where(created_at: awal..Time.current).where.not(status: "dibatalkan")
      render json: {
        nomor_meja: meja.nomor_meja,
        mulai_kunjungan: awal,
        total: pesanan.sum(:total_harga),
        jumlah_pesanan: pesanan.count,
        pesanan: pesanan.map { |p| { kode: p.kode_pesanan, status: p.status, total: p.total_harga } }
      }
    end
  end
end
