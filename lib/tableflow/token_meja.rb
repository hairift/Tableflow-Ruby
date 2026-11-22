# Pembuatan dan verifikasi token QR meja memakai HMAC-SHA256.
# Rahasia setiap meja berbeda sehingga token tidak dapat ditebak dari nomor meja.
module Tableflow
  module TokenMeja
    POLA_TOKEN = /\A[0-9a-f]{64}\z/

    def self.buat(nomor_meja, rahasia)
      OpenSSL::HMAC.hexdigest("SHA256", rahasia, "meja:#{nomor_meja}")
    end

    # Mengembalikan meja bila token sah, aktif, dan cocok dengan HMAC yang tersimpan.
    def self.verifikasi(token)
      return nil unless token.to_s.match?(POLA_TOKEN)

      meja = Meja.find_by(token_qr: token)
      return nil if meja.blank? || !meja.aktif?

      hasil = buat(meja.nomor_meja, meja.rahasia_token)
      return nil unless ActiveSupport::SecurityUtils.secure_compare(hasil, token)

      meja
    end
  end
end
