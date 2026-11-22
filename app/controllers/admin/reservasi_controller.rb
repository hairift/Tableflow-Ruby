# Pengelolaan reservasi meja dan uang muka.
module Admin
  class ReservasiController < BaseController
    before_action :atur_reservasi, only: %i[show edit update destroy]

    def index
      @reservasi = Reservasi.includes(:meja).mendatang
    end

    def show; end

    def new
      @reservasi = Reservasi.new(tanggal_reservasi: 1.day.from_now)
    end

    def edit; end

    def create
      @reservasi = Reservasi.new(parameter_reservasi)
      if @reservasi.meja_dapat_dipakai? && @reservasi.save
        redirect_to admin_reservasi_path(@reservasi), notice: "Reservasi dicatat."
      else
        flash.now[:alert] = "Meja tidak cukup besar atau sudah dipesan pada waktu tersebut."
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @reservasi.update(parameter_reservasi) && @reservasi.meja_dapat_dipakai?
        redirect_to admin_reservasi_path(@reservasi), notice: "Reservasi diperbarui."
      else
        flash.now[:alert] = "Data tidak valid atau meja bentrok."
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @reservasi.destroy
      redirect_to admin_reservasi_index_path, notice: "Reservasi dihapus."
    end

    private

    def atur_reservasi
      @reservasi = Reservasi.find(params[:id])
    end

    def parameter_reservasi
      params.require(:reservasi).permit(
        :nama_pelanggan, :nama_acara, :telepon, :jumlah_tamu, :tanggal_reservasi,
        :meja_id, :status, :catatan, :jumlah_deposit, :deposit_lunas, :metode_deposit
      )
    end
  end
end
