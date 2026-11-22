# Salinan pilihan varian pada saat pemesanan, terpisah dari data varian menu.
class VarianItemPesanan < ApplicationRecord
  self.table_name = "varian_item_pesanan"

  belongs_to :item_pesanan, inverse_of: :varian_item_pesanan

  validates :nama_grup, presence: true
  validates :nama_opsi, presence: true
end
