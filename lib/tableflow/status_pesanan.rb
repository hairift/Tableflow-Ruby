# Aturan transisi status pesanan dan status yang masih dianggap aktif.
module Tableflow
  module StatusPesanan
    LANJUTAN = {
      "dikonfirmasi" => "dimasak",
      "dimasak" => "siap",
      "siap" => "selesai"
    }.freeze

    # Semua perpindahan yang diizinkan, termasuk konfirmasi pembayaran.
    PERPINDAHAN = {
      "menunggu" => %w[menunggu_verifikasi dikonfirmasi dibatalkan],
      "menunggu_verifikasi" => %w[dikonfirmasi dibatalkan],
      "dikonfirmasi" => %w[dimasak dibatalkan],
      "dimasak" => %w[siap dibatalkan],
      "siap" => %w[selesai dibatalkan]
    }.freeze

    DAPAT_DIBATALKAN = %w[menunggu menunggu_verifikasi dikonfirmasi dimasak siap].freeze
    SUDAH_LUNAS = %w[dikonfirmasi dimasak siap].freeze
    PENDAPATAN = %w[dikonfirmasi dimasak siap selesai].freeze
    AKHIR = %w[selesai dibatalkan].freeze

    # Rantai status dapur untuk tombol lanjut, bukan validasi perpindahan.
    def self.lanjutan(status)
      LANJUTAN[status]
    end

    def self.boleh_berpindah?(dari, ke)
      PERPINDAHAN.fetch(dari, []).include?(ke)
    end

    def self.dapat_dibatalkan?(status)
      DAPAT_DIBATALKAN.include?(status)
    end

    def self.sudah_lunas?(status)
      SUDAH_LUNAS.include?(status)
    end
  end
end
