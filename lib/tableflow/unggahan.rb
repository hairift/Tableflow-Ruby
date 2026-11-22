# Pemeriksaan berkas unggahan berdasarkan tanda tangan biner, bukan hanya nama berkas.
module Tableflow
  module Unggahan
    UKURAN_MAKSIMAL = 2.megabytes
    TANDA_PNG = "\x89PNG\r\n\x1A\n".b
    TANDA_JPG = "\xFF\xD8\xFF".b
    TANDA_WEBP = "WEBP".b

    def self.gambar_valid?(berkas)
      return false if berkas.blank?
      return false if berkas.size > UKURAN_MAKSIMAL

      kepala = berkas.read(16)
      berkas.rewind
      return true if kepala&.start_with?(TANDA_PNG)
      return true if kepala&.start_with?(TANDA_JPG)
      return true if kepala&.start_with?("RIFF".b) && kepala.byteslice(8, 4) == TANDA_WEBP

      false
    rescue StandardError
      false
    end

    def self.nama_aman(nama_asli)
      dasar = File.basename(nama_asli.to_s).parameterize
      dasar = "gambar" if dasar.blank?
      "#{SecureRandom.hex(8)}-#{dasar}"
    end
  end
end
