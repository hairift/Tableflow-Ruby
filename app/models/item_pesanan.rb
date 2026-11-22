# Baris menu dalam sebuah pesanan. Harga disimpan salinan agar tidak berubah saat menu diedit.
class ItemPesanan < ApplicationRecord
  self.table_name = "item_pesanan"

  belongs_to :pesanan, inverse_of: :item_pesanan
  belongs_to :produk, inverse_of: :item_pesanan
  has_many :varian_item_pesanan, foreign_key: :item_pesanan_id, inverse_of: :item_pesanan, dependent: :destroy

  validates :jumlah, numericality: { only_integer: true, greater_than: 0 }
  validates :harga_saat_pesan, numericality: { greater_than_or_equal_to: 0 }

  def subtotal
    jumlah * harga_saat_pesan
  end
end
