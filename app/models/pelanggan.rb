# Member loyalitas yang dikenali lewat nomor telepon.
class Pelanggan < ApplicationRecord
  self.table_name = "pelanggan"

  has_many :pesanan, foreign_key: :pelanggan_id, inverse_of: :pelanggan, dependent: :restrict_with_error

  validates :telepon, presence: true, uniqueness: true
  validates :poin, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :berpoin, -> { where("poin > 0").order(poin: :desc) }

  def tingkat_tertinggi
    TingkatLoyalitas.where("min_poin <= ?", poin).order(min_poin: :desc).first
  end
end
