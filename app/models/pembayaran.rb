# Data pembayaran sebuah pesanan, termasuk bukti transfer QRIS dan verifikasi petugas.
class Pembayaran < ApplicationRecord
  self.table_name = "pembayaran"

  METODE = %w[qris tunai debit].freeze

  belongs_to :pesanan, inverse_of: :pembayaran
  belongs_to :diverifikasi_oleh, class_name: "Pengguna", optional: true, inverse_of: :pembayaran

  validates :metode, inclusion: { in: METODE }
  validates :jumlah, numericality: { greater_than_or_equal_to: 0 }

  def kembalian
    return nil if uang_diterima.blank?

    uang_diterima - jumlah
  end
end
