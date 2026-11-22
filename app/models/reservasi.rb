# Reservasi meja untuk acara atau kunjungan di masa mendatang.
class Reservasi < ApplicationRecord
  self.table_name = "reservasi"

  STATUS = %w[menunggu dikonfirmasi dibatalkan selesai].freeze
  METODE = %w[qris tunai debit].freeze

  belongs_to :meja, optional: true, inverse_of: :reservasi

  validates :nama_pelanggan, presence: true
  validates :jumlah_tamu, numericality: { only_integer: true, greater_than: 0 }
  validates :tanggal_reservasi, presence: true
  validates :status, inclusion: { in: STATUS }
  validates :jumlah_deposit, numericality: { greater_than_or_equal_to: 0 }
  validates :metode_deposit, inclusion: { in: METODE }, allow_nil: true

  enum :status, STATUS.index_with { |nilai| nilai }

  scope :mendatang, -> { where("tanggal_reservasi >= ?", Time.current).order(:tanggal_reservasi) }
  scope :terbaru, -> { order(tanggal_reservasi: :desc) }

  # Meja harus cukup besar dan tidak bentrok dalam jendela tiga jam.
  def meja_dapat_dipakai?
    return false if meja.blank? || jumlah_tamu > meja.kapasitas

    batas_awal = tanggal_reservasi - 3.hours
    batas_akhir = tanggal_reservasi + 3.hours
    bentrok = Reservasi.where(meja_id: meja_id, status: %w[menunggu dikonfirmasi])
                       .where(tanggal_reservasi: batas_awal..batas_akhir)
    bentrok = bentrok.where.not(id: id) if persisted?
    bentrok.none?
  end
end
