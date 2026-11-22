# Ambang poin yang memberi diskon tertentu pada pelanggan.
class TingkatLoyalitas < ApplicationRecord
  self.table_name = "tingkat_loyalitas"

  BATAS_DISKON = 25

  validates :min_poin, presence: true, uniqueness: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :persen_diskon, numericality: { greater_than: 0, less_than_or_equal_to: BATAS_DISKON }

  scope :terurut, -> { order(:min_poin) }
end
