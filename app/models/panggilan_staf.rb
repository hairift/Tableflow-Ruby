# Panggilan bantuan dari pelanggan tanpa harus memesan sesuatu.
class PanggilanStaf < ApplicationRecord
  self.table_name = "panggilan_staf"

  STATUS = %w[menunggu selesai].freeze

  belongs_to :meja, inverse_of: :panggilan_staf
  belongs_to :diselesaikan_oleh, class_name: "Pengguna", optional: true, inverse_of: :panggilan_staf

  validates :status, inclusion: { in: STATUS }

  enum :status, STATUS.index_with { |nilai| nilai }

  scope :menunggu, -> { where(status: "menunggu") }
  scope :terbaru, -> { order(created_at: :desc) }
end
