# Meja fisik di kafe yang dapat dipindai melalui kode QR unik.
class Meja < ApplicationRecord
  self.table_name = "meja"

  has_many :pesanan, foreign_key: :meja_id, inverse_of: :meja, dependent: :restrict_with_error
  has_many :panggilan_staf, foreign_key: :meja_id, inverse_of: :meja, dependent: :destroy
  has_many :reservasi, foreign_key: :meja_id, inverse_of: :meja, dependent: :restrict_with_error

  validates :nomor_meja, presence: true, uniqueness: true
  validates :kapasitas, numericality: { only_integer: true, greater_than: 0 }

  before_validation :buat_token_qr, on: :create

  scope :aktif, -> { where(aktif: true) }

  # Kunjungan dianggap masih berjalan bila masih ada pesanan yang belum selesai.
  def ada_kunjungan_aktif?
    pesanan.where.not(status: %w[selesai dibatalkan]).exists?
  end

  def reset_token_qr!
    self.rahasia_token = SecureRandom.hex(32)
    self.token_qr = Tableflow::TokenMeja.buat(nomor_meja, rahasia_token)
    save!
  end

  private

  def buat_token_qr
    self.rahasia_token = SecureRandom.hex(32)
    self.token_qr = Tableflow::TokenMeja.buat(nomor_meja, rahasia_token)
  end
end
