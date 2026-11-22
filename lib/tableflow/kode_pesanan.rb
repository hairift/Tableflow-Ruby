# Kode pesanan harian yang mudah dibaca dan bebas huruf yang mirip satu sama lain.
module Tableflow
  module KodePesanan
    ABJAD = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789".freeze
    PANJANG_AKHIR = 4

    def self.buat(waktu = Time.current)
      tanggal = waktu.in_time_zone("Asia/Jakarta").strftime("%Y%m%d")
      akhir = Array.new(PANJANG_AKHIR) { ABJAD[SecureRandom.random_number(ABJAD.length)] }.join
      "TF-#{tanggal}-#{akhir}"
    end
  end
end
