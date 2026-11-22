# Kelompok menu yang mengurutkan produk di tampilan pelanggan.
class Kategori < ApplicationRecord
  self.table_name = "kategori"

  has_many :produk, foreign_key: :kategori_id, inverse_of: :kategori, dependent: :restrict_with_error

  validates :nama, presence: true, uniqueness: true
  validates :urutan, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :estimasi_menit, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  scope :aktif, -> { where(aktif: true) }
  scope :terurut, -> { order(:urutan, :nama) }
end
