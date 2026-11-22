# Pengelolaan akun petugas dan wewenangnya.
module Admin
  class PenggunaController < BaseController
    before_action :butuh_admin
    before_action :atur_pengguna, only: %i[edit update destroy]

    def index
      @pengguna = Pengguna.order(:username)
    end

    def new
      @pengguna = Pengguna.new
    end

    def edit; end

    def create
      @pengguna = Pengguna.new(parameter_pengguna)
      if @pengguna.save
        redirect_to admin_pengguna_index_path, notice: "Akun petugas dibuat."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @pengguna.update(parameter_pengguna)
        redirect_to admin_pengguna_index_path, notice: "Akun petugas diperbarui."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @pengguna.id == petugas_saat_ini.id
        redirect_to admin_pengguna_index_path, alert: "Akun sendiri tidak dapat dihapus."
      else
        @pengguna.destroy
        redirect_to admin_pengguna_index_path, notice: "Akun petugas dihapus."
      end
    end

    private

    def atur_pengguna
      @pengguna = Pengguna.find(params[:id])
    end

    def parameter_pengguna
      nilai = params.require(:pengguna).permit(:username, :peran, :aktif, :kata_sandi, :pin)
      nilai.delete(:kata_sandi) if nilai[:kata_sandi].blank?
      nilai.delete(:pin) if nilai[:pin].blank?
      nilai
    end
  end
end
