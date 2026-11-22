# Pembatasan laju permintaan untuk mencegah serangan brute force dan penyalahgunaan endpoint.
class Rack::Attack
  THROTTLE = ActiveSupport::Cache::MemoryStore.new(size: 10_000)

  def self.cache
    THROTTLE
  end

  # Permintaan dari alamat yang sama tidak boleh membanjiri seluruh aplikasi.
  throttle("semua/ip", limit: 300, period: 5.minutes) do |permintaan|
    permintaan.ip
  end

  # Percobaan masuk gagal dibatasi per alamat dan nama pengguna.
  throttle("masuk/ip", limit: 10, period: 5.minutes) do |permintaan|
    permintaan.ip if permintaan.path == "/masuk" && permintaan.post?
  end

  throttle("masuk/nama", limit: 5, period: 5.minutes) do |permintaan|
    next unless permintaan.path == "/masuk" && permintaan.post?

    nama = permintaan.params.dig("sesi", "username").to_s.downcase
    "#{permintaan.ip}:#{nama}" if nama.present?
  end

  # Pembuatan pesanan dibatasi agar satu meja tidak membuat pesanan berulang.
  throttle("pesanan/meja", limit: 10, period: 1.minute) do |permintaan|
    permintaan.ip if permintaan.path == "/api/publik/pesanan" && permintaan.post?
  end

  # Pengecekan status dibatasi untuk mencegah perumusan kode pesanan.
  throttle("status/kode", limit: 20, period: 1.minute) do |permintaan|
    permintaan.ip if permintaan.path.start_with?("/api/publik/pesanan/") && permintaan.get?
  end

  # Panggilan staf dibatasi agar tidak mengganggu operasional.
  throttle("panggilan/ip", limit: 5, period: 1.minute) do |permintaan|
    permintaan.ip if permintaan.path == "/api/publik/panggilan-staf" && permintaan.post?
  end

  # Kunci API eksternal juga memiliki batas pemakaian.
  throttle("eksternal/kunci", limit: 60, period: 1.minute) do |permintaan|
    permintaan.get_header("HTTP_X_TABLEFLOW_KEY") if permintaan.path.start_with?("/api/eksternal/")
  end

  safelist("local") do |permintaan|
    Rails.env.development? && %w[127.0.0.1 ::1].include?(permintaan.ip)
  end

  self.throttled_responder = lambda do |permintaan|
    [
      429,
      { "Content-Type" => "application/json; charset=utf-8" },
      [{ error: "Terlalu banyak permintaan. Coba lagi beberapa saat lagi." }.to_json]
    ]
  end
end
