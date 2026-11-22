# Periksa semua helper rute yang dipakai di aplikasi terhadap rute yang terdaftar.
require_relative "../config/environment"

Rails.application.reload_routes!
helpers = Rails.application.routes.named_routes.helper_names.map(&:to_s)
template = /([a-z][a-z0-9_]*(?:_[a-z0-9_]+)*?)_(?:path|url)\b/

Dir.glob("{app/views,app/controllers,app/helpers}/**/*.{erb,rb}").sort.each do |path|
  File.readlines(path).each_with_index do |baris, indeks|
    baris.scan(template).flatten.each do |nama|
      penuh = "#{nama}_path"
      next if helpers.include?(penuh) || helpers.include?("#{nama}_url")

      puts "TIDAK ADA #{penuh} di #{path}:#{indeks + 1}"
    end
  end
end

puts "Selesai cek rute"
