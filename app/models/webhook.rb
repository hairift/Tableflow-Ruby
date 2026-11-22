# Langganan kejadian untuk sistem eksternal dengan penandatanganan HMAC.
class Webhook < ApplicationRecord
  self.table_name = "webhook"

  EVENT = %w[pesanan.dibuat pesanan.status_berubah].freeze

  validates :url, presence: true
  validates :daftar_event, presence: true
  validates :rahasia, presence: true
  validate :url_harus_valid

  scope :aktif, -> { where(aktif: true) }

  def daftar_event_array
    daftar_event.to_s.split(",").map(&:strip).reject(&:blank?)
  end

  def mengirim?(nama_event)
    aktif? && daftar_event_array.include?(nama_event)
  end

  private

  def url_harus_valid
    Tableflow::PengamanUrl.pasti_aman!(url)
  rescue Tableflow::PengamanUrl::Ditolak => e
    errors.add(:url, e.message)
  end
end
