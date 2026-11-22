# Akun petugas. Kata sandi dan PIN disimpan sebagai hash bcrypt.
class Pengguna < ApplicationRecord
  self.table_name = "pengguna"

  PERAN = %w[admin kasir].freeze

  has_many :log_status_pesanan, foreign_key: :diubah_oleh, inverse_of: :diubah_oleh
  has_many :pembayaran, foreign_key: :diverifikasi_oleh, inverse_of: :diverifikasi_oleh
  has_many :panggilan_staf, foreign_key: :diselesaikan_oleh, inverse_of: :diselesaikan_oleh
  has_many :shift, foreign_key: :pengguna_id, inverse_of: :pengguna, dependent: :restrict_with_error

  validates :username, presence: true, uniqueness: true, length: { minimum: 3 }
  validates :peran, inclusion: { in: PERAN }
  validates :hash_kata_sandi, presence: true

  scope :aktif, -> { where(aktif: true) }

  def kata_sandi=(nilai)
    self.hash_kata_sandi = BCrypt::Password.create(nilai, cost: 12) if nilai.present?
  end

  def cocok_kata_sandi?(nilai)
    return false if nilai.blank? || hash_kata_sandi.blank?

    BCrypt::Password.new(hash_kata_sandi) == nilai
  end

  def pin=(nilai)
    self.hash_pin = BCrypt::Password.create(nilai, cost: 12) if nilai.present?
  end

  def cocok_pin?(nilai)
    return false if nilai.blank? || hash_pin.blank?

    BCrypt::Password.new(hash_pin) == nilai
  end

  def admin?
    peran == "admin"
  end
end
