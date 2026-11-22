# Catatan setiap perubahan status pesanan untuk keperluan audit.
class LogStatusPesanan < ApplicationRecord
  self.table_name = "log_status_pesanan"

  belongs_to :pesanan, inverse_of: :log_status_pesanan
  belongs_to :diubah_oleh, class_name: "Pengguna", optional: true, inverse_of: :log_status_pesanan

  validates :status_dari, presence: true
  validates :status_ke, presence: true

  scope :terbaru, -> { order(created_at: :desc) }
end
