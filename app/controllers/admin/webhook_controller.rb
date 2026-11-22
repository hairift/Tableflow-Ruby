# Langganan kejadian untuk sistem eksternal.
module Admin
  class WebhookController < BaseController
    before_action :butuh_admin

    def index
      @webhook = Webhook.order(created_at: :desc)
      @rahasia_baru = session.delete(:rahasia_baru)
    end

    def create
      rahasia = SecureRandom.hex(24)
      Webhook.create!(
        url: params[:url],
        daftar_event: Array(params[:event]).join(","),
        rahasia: rahasia
      )
      session[:rahasia_baru] = rahasia
      redirect_to admin_webhook_index_path, notice: "Webhook didaftarkan."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to admin_webhook_index_path, alert: e.record.errors.full_messages.first
    rescue Tableflow::PengamanUrl::Ditolak => e
      redirect_to admin_webhook_index_path, alert: e.message
    end

    def destroy
      Webhook.find(params[:id]).destroy
      redirect_to admin_webhook_index_path, notice: "Webhook dihapus."
    end
  end
end
