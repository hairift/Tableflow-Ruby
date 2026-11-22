# Pencegahan SSRF: menolak alamat yang mengarah ke jaringan internal atau metadata.
module Tableflow
  module PengamanUrl
    class Ditolak < StandardError; end

    ALAMAT_TERLARANG = %w[
      localhost 127.0.0.1 0.0.0.0 ::1 169.254.169.254
      metadata.google.internal metadata.goog
    ].freeze

    JARINGAN_PRIVATE = %w[10. 172.16. 172.17. 172.18. 172.19. 172.2 172.3 192.168.].freeze

    def self.pasti_aman!(url)
      uri = URI.parse(url.to_s)
      raise Ditolak, "Skema URL harus http atau https." unless %w[http https].include?(uri.scheme)
      raise Ditolak, "Nama host tidak ditemukan." if uri.host.blank?

      host = uri.host.downcase
      raise Ditolak, "Alamat tujuan tidak diizinkan." if ALAMAT_TERLARANG.any? { |a| host.include?(a) }
      if host.match?(/\A\d+\.\d+\.\d+\.\d+\z/) && JARINGAN_PRIVATE.any? { |j| host.start_with?(j) }
        raise Ditolak, "Alamat jaringan internal tidak diizinkan."
      end

      alamat = Resolv.getaddresses(host)
      raise Ditolak, "Host tidak dapat diresolusi." if alamat.empty?
      if alamat.any? { |a| a.start_with?("10.", "192.168.", "127.", "169.254.") }
        raise Ditolak, "Host mengarah ke jaringan internal."
      end

      uri
    rescue URI::InvalidURIError, Resolv::ResolvError
      raise Ditolak, "Alamat URL tidak valid."
    end
  end
end
