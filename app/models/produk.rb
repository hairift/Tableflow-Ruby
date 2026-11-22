# Menu yang dijual kafe, lengkap dengan varian dan pengelolaan stok opsional.
class Produk < ApplicationRecord
  self.table_name = "produk"

  belongs_to :kategori, inverse_of: :produk
  has_many :grup_varian, foreign_key: :produk_id, inverse_of: :produk, dependent: :destroy
  has_many :item_pesanan, foreign_key: :produk_id, inverse_of: :produk, dependent: :restrict_with_error

  accepts_nested_attributes_for :grup_varian, allow_destroy: true

  validates :nama, presence: true
  validates :harga, numericality: { greater_than_or_equal_to: 0 }
  validates :harga_modal, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :stok, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :tersedia, -> { where(tersedia: true) }
  scope :untuk_publik, -> { tersedia.joins(:kategori).merge(Kategori.aktif).order("kategori.urutan", :nama) }

  def harga_setelah_varian(opsi_ids)
    tambahan = OpsiVarian.where(id: opsi_ids).sum(:harga_tambahan)
    harga + tambahan
  end
end
