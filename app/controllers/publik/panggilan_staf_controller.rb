# Permintaan bantuan sederhana dari meja tanpa membuat pesanan.
module Publik
  class PanggilanStafController < ApplicationController
    ALASAN = %w[air minum alat\ makan bantuan menu tagihan].freeze

    def create
      meja = Tableflow::TokenMeja.verifikasi(params[:token])
      return gagal("Token meja tidak valid.", status: :forbidden) if meja.blank?

      alasan = params[:alasan].to_s
      return gagal("Alasan tidak dikenal.") unless ALASAN.include?(alasan)

      panggilan = PanggilanStaf.create!(
        meja: meja,
        catatan: [alasan, params[:catatan]].compact.join(" - "),
        status: "menunggu"
      )
      render json: { id: panggilan.id, status: panggilan.status, dibuat_pada: panggilan.created_at },
             status: :created
    end
  end
end
