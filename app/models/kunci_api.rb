# Kunci akses untuk integrasi eksternal. Kunci asli hanya ditampilkan sekali saat dibuat.
class KunciApi < ApplicationRecord
  self.table_name = "kunci_api"

  validates :nama, presence: true
  validates :hash_kunci, presence: true, uniqueness: true

  scope :aktif, -> { where(dicabut_pada: nil) }

  def self.terbitkan(nama)
    kunci_mentah = SecureRandom.hex(24)
    catatan = create!(
      nama: nama,
      hash_kunci: Digest::SHA256.hexdigest(kunci_mentah),
      akhir_kunci: kunci_mentah.last(6)
    )
    [catatan, kunci_mentah]
  end

  def cocok?(kunci_mentah)
    return false if dicabut_pada.present?

    ActiveSupport::SecurityUtils.secure_compare(
      hash_kunci,
      Digest::SHA256.hexdigest(kunci_mentah.to_s)
    )
  end

  def tandai_dipakai!
    update_column(:digunakan_pada, Time.current)
  end
end
