# Pengaturan toko berupa satu baris data tunggal.
class PengaturanToko < ApplicationRecord
  self.table_name = "pengaturan_toko"

  validates :persen_pajak, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :persen_biaya_layanan, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  def self.saat_ini
    find_or_create_by!(id: 1)
  end

  def nama_tampil
    nama_toko.presence || "Tableflow-Scan"
  end
end
