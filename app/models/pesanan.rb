# Pesanan pelanggan, baik dari pemindaian QR meja maupun input manual petugas.
class Pesanan < ApplicationRecord
  self.table_name = "pesanan"

  STATUS = %w[menunggu menunggu_verifikasi dikonfirmasi dimasak siap selesai dibatalkan].freeze
  METODE = %w[qris tunai debit].freeze

  belongs_to :meja, optional: true, inverse_of: :pesanan
  belongs_to :pelanggan, optional: true, inverse_of: :pesanan
  has_many :item_pesanan, foreign_key: :pesanan_id, inverse_of: :pesanan, dependent: :destroy
  has_one :pembayaran, foreign_key: :pesanan_id, inverse_of: :pesanan, dependent: :destroy
  has_many :log_status_pesanan, foreign_key: :pesanan_id, inverse_of: :pesanan, dependent: :destroy

  accepts_nested_attributes_for :item_pesanan, allow_destroy: true

  enum :status, STATUS.index_with { |nilai| nilai }
  enum :metode, METODE.index_with { |nilai| nilai }

  validates :kode_pesanan, presence: true, uniqueness: true
  validates :metode, inclusion: { in: METODE }
  validates :total_harga, numericality: { greater_than_or_equal_to: 0 }
  validates :kunci_idempotensi, uniqueness: true, allow_nil: true

  scope :terbaru, -> { order(created_at: :desc) }
  scope :berjalan, -> { where.not(status: %w[selesai dibatalkan]) }
  scope :pendapatan, -> { where(status: %w[dikonfirmasi dimasak siap selesai]) }

  def dapat_dibatalkan?
    %w[menunggu menunggu_verifikasi dikonfirmasi dimasak siap].include?(status)
  end

  def sudah_lunas?
    %w[dikonfirmasi dimasak siap].include?(status)
  end

  def subtotal
    item_pesanan.sum("jumlah * harga_saat_pesan")
  end

  # Kode pesanan tidak diubah lagi setelah dibuat agar riwayat tetap konsisten.
  def kode_pesanan=(nilai)
    super if new_record?
  end
end
