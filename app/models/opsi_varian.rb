# Opsi di dalam grup varian yang dapat menambah harga satuan produk.
class OpsiVarian < ApplicationRecord
  self.table_name = "opsi_varian"

  belongs_to :grup, class_name: "GrupVarian", inverse_of: :opsi_varian

  validates :nama, presence: true
  validates :harga_tambahan, numericality: { greater_than_or_equal_to: 0 }
  validates :urutan, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :terurut, -> { order(:urutan, :id) }
end
