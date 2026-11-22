# Pengiriman kejadian ke webhook eksternal dengan tanda tangan HMAC.
module Tableflow
  module PengirimWebhook
    BATAS_WAKTU = 5

    def self.kirim(nama_event, pesanan)
      return if pesanan.blank?

      Webhook.aktif.each do |webhook|
        next unless webhook.mengirim?(nama_event)

        uri = PengamanUrl.pasti_aman!(webhook.url)
        isi = {
          event: nama_event,
          waktu: Time.current.iso8601,
          data: {
            kode_pesanan: pesanan.kode_pesanan,
            status: pesanan.status,
            metode: pesanan.metode,
            total_harga: pesanan.total_harga.to_s
          }
        }.to_json
        tanda_tangan = OpenSSL::HMAC.hexdigest("SHA256", webhook.rahasia, isi)

        Thread.new do
          permintaan = Net::HTTP::Post.new(uri)
          permintaan["Content-Type"] = "application/json"
          permintaan["X-Tableflow-Signature"] = tanda_tangan
          permintaan.body = isi
          Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                          open_timeout: BATAS_WAKTU, read_timeout: BATAS_WAKTU) do |http|
            http.request(permintaan)
          end
        rescue StandardError
          # Pengiriman gagal tidak boleh menggagalkan aksi petugas atau pelanggan.
          nil
        end
      rescue Tableflow::PengamanUrl::Ditolak
        next
      end
    end
  end
end
