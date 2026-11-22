# Antrean panggilan bantuan dari meja pelanggan.
module Admin
  class PanggilanStafController < BaseController
    def index
      @panggilan = PanggilanStaf.includes(:meja).terbaru
    end

    def update
      panggilan = PanggilanStaf.find(params[:id])
      panggilan.update!(
        status: "selesai",
        diselesaikan_oleh: petugas_saat_ini,
        diselesaikan_pada: Time.current
      )
      redirect_to admin_panggilan_staf_index_path, notice: "Panggilan ditandai selesai."
    end
  end
end
