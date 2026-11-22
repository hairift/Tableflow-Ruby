# Daftar member loyalitas dan riwayat poin mereka.
module Admin
  class PelangganController < BaseController
    def index
      @pelanggan = Pelanggan.order(poin: :desc, created_at: :desc)
    end

    def show
      @pelanggan = Pelanggan.includes(pesanan: :meja).find(params[:id])
    end
  end
end
