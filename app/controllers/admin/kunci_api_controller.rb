# Penerbitan dan pencabutan kunci akses untuk integrasi eksternal.
module Admin
  class KunciApiController < BaseController
    before_action :butuh_admin

    def index
      @kunci = KunciApi.order(created_at: :desc)
      @kunci_baru = session.delete(:kunci_baru)
    end

    def create
      catatan, kunci_mentah = KunciApi.terbitkan(params[:nama])
      session[:kunci_baru] = kunci_mentah
      redirect_to admin_kunci_api_index_path, notice: "Kunci untuk #{catatan.nama} diterbitkan."
    end

    def destroy
      kunci = KunciApi.find(params[:id])
      kunci.update!(dicabut_pada: Time.current)
      redirect_to admin_kunci_api_index_path, notice: "Kunci dicabut."
    end
  end
end
