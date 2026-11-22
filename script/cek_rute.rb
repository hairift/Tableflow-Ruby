# Periksa helper rute yang dipakai di aplikasi terhadap rute yang terdaftar.
require_relative "../config/environment"

Rails.application.reload_routes!
helpers = Rails.application.routes.named_routes.helper_names.map(&:to_s)
template = /([a-z][a-z0-9_]*(?:_[a-z0-9_]+)*?)_(?:path|url)\b/

# Bukan helper rute: method Rails biasa dan kunci JSON pada berkas PWA.
DIABAIKAN = %w[controller base].freeze
sudah_dilaporkan = {}

Dir.glob("{app/views,app/controllers,app/helpers}/**/*.{erb,rb}").sort.each do |path|
  File.readlines(path).each_with_index do |baris, indeks|
    baris = baris.gsub(/<%#.*?%>/, "")
    baris.scan(template).flatten.each do |nama|
      next if DIABAIKAN.include?(nama)
      next if baris.match?(/"#{nama}_url"\s*:/)

      penuh = "#{nama}_path"
      next if helpers.include?(penuh) || helpers.include?("#{nama}_url")

      kunci = "#{penuh} di #{path}:#{indeks + 1}"
      next if sudah_dilaporkan[kunci]

      sudah_dilaporkan[kunci] = true
      puts "TIDAK ADA #{kunci}"
    end
  end
end

puts "Selesai cek rute"
