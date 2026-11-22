# Masa kerja petugas di kasir, dipakai untuk rekonsiliasi kas.
class Shift < ApplicationRecord
  self.table_name = "shift"

  belongs_to :pengguna, inverse_of: :shift

  validates :mulai_pada, presence: true
  validates :kas_awal, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :kas_hitung, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :berjalan, -> { where(selesai_pada: nil) }
  scope :terbaru, -> { order(mulai_pada: :desc) }

  # Pendapatan tunai dihitung dari pesanan yang dibuat selama masa kerja ini.
  def pendapatan_tunai
    Pesanan.pendapatan
           .where(metode: "tunai", created_at: mulai_pada..(selesai_pada || Time.current))
           .sum(:total_harga)
  end

  def kas_expected
    (kas_awal || 0) + pendapatan_tunai
  end

  def selisih_kas
    return nil if kas_hitung.blank?

    kas_hitung - kas_expected
  end
end
