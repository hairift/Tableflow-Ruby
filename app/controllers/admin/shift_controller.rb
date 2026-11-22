# Mulai dan akhiri masa kerja kasir berikut rekonsiliasi kas.
module Admin
  class ShiftController < BaseController
    def index
      @shift_berjalan = Shift.berjalan.includes(:pengguna)
      @shift_selesai = Shift.where.not(selesai_pada: nil).includes(:pengguna).terbaru.limit(30)
      @shift = Shift.new
    end

    def create
      shift = Shift.new(
        pengguna: petugas_saat_ini,
        nama_staf: params[:nama_staf],
        kas_awal: params[:kas_awal],
        mulai_pada: Time.current
      )
      if shift.save
        redirect_to admin_shift_index_path, notice: "Shift dimulai."
      else
        redirect_to admin_shift_index_path, alert: shift.errors.full_messages.first
      end
    end

    def selesai
      shift = Shift.berjalan.find(params[:id])
      shift.update!(
        selesai_pada: Time.current,
        kas_hitung: params[:kas_hitung],
        jumlah_gojek: params[:jumlah_gojek],
        jumlah_grabfood: params[:jumlah_grabfood]
      )
      redirect_to admin_shift_index_path, notice: "Shift ditutup."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to admin_shift_index_path, alert: e.record.errors.full_messages.first
    end

    def update
      shift = Shift.find(params[:id])
      shift.update!(nama_staf: params[:nama_staf])
      redirect_to admin_shift_index_path, notice: "Data shift diperbarui."
    end
  end
end
