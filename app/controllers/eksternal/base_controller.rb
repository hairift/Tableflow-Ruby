# Induk API eksternal yang memakai kunci akses, bukan sesi petugas.
module Eksternal
  class BaseController < ApplicationController
    skip_forgery_protection
    before_action :otentikasi_kunci

    private

    def otentikasi_kunci
      kunci_mentah = request.get_header("HTTP_X_TABLEFLOW_KEY")
      kunci = KunciApi.aktif.find { |item| item.cocok?(kunci_mentah) }
      return render json: { error: "Kunci API tidak valid." }, status: :unauthorized if kunci.blank?

      kunci.tandai_dipakai!
    end
  end
end
