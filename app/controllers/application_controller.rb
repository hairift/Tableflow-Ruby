# Induk seluruh pengontrol: otentikasi, wewenang, dan respons kesalahan terpusat.
class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  protect_from_forgery with: :exception

  layout :pilih_layout

  helper_method :petugas_saat_ini, :admin?, :kasir?, :nama_toko

  private

  # Tampilan pelanggan dan panel petugas memakai kerangka berbeda.
  def pilih_layout
    return "panel" if controller_path.start_with?("admin/") || controller_path == "sesi"

    "publik"
  end

  def petugas_saat_ini
    @petugas_saat_ini ||= Pengguna.aktif.find_by(id: session[:petugas_id])
  end

  def admin?
    petugas_saat_ini&.admin?
  end

  def kasir?
    petugas_saat_ini.present?
  end

  def nama_toko
    PengaturanToko.saat_ini.nama_tampil
  end

  def butuh_petugas
    return if petugas_saat_ini

    session[:alamat_tujuan] = request.fullpath
    redirect_to halaman_masuk_path, alert: "Silakan masuk terlebih dahulu."
  end

  def butuh_admin
    butuh_petugas
    return if admin? || performed?

    redirect_to admin_dashboard_path, alert: "Halaman ini hanya untuk admin."
  end

  def gagal(pesan, status: :unprocessable_entity)
    render json: { error: pesan }, status: status
  end

  def aman_nama_berkas(nama)
    nama = File.basename(nama.to_s)
    return nil unless nama.match?(/\A[a-f0-9]{16}-[a-z0-9-]+\.(png|jpg|jpeg|webp)\z/)

    nama
  end
end
