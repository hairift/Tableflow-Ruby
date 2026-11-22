# Ringkasan operasional harian untuk petugas.
module Admin
  class DashboardController < BaseController
    def index
      hari_ini = Tableflow::Waktu.rentang_hari
      @shift_aktif = Shift.berjalan.includes(:pengguna)
      @pesanan_berjalan = Pesanan.berjalan.where(created_at: hari_ini).includes(:meja).order(:created_at)
      @panggilan_menunggu = PanggilanStaf.menunggu.includes(:meja)
      @pendapatan_hari_ini = Pesanan.pendapatan.where(created_at: hari_ini).sum(:total_harga)
      @jumlah_pesanan = Pesanan.where(created_at: hari_ini).count
      @menunggu_verifikasi = Pesanan.where(status: "menunggu_verifikasi").count
      @meja_sibuk = Meja.aktif.select(&:ada_kunjungan_aktif?)
    end
  end
end
