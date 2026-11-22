# Grup pilihan pada sebuah produk, misalnya ukuran atau tingkat kematangan.
class GrupVarian < ApplicationRecord
  self.table_name = "grup_varian"

  belongs_to :produk, inverse_of: :grup_varian
  has_many :opsi_varian, foreign_key: :grup_id, inverse_of: :grup, dependent: :destroy

  accepts_nested_attributes_for :opsi_varian, allow_destroy: true

  validates :nama, presence: true
  validates :urutan, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :terurut, -> { order(:urutan, :id) }
end
