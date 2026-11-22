# Otentikasi petugas berbasis sesi dan kata sandi bcrypt.
class SesiController < ApplicationController
  def new; end

  def create
    pengguna = Pengguna.aktif.find_by(username: params[:username].to_s.strip.downcase)

    if pengguna&.cocok_kata_sandi?(params[:kata_sandi])
      reset_session
      session[:petugas_id] = pengguna.id
      tujuan = session.delete(:alamat_tujuan) || admin_dashboard_path
      redirect_to tujuan, notice: "Selamat datang, #{pengguna.username}."
    else
      flash.now[:alert] = "Nama pengguna atau kata sandi tidak benar."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to halaman_masuk_path, notice: "Sesi berakhir."
  end
end
