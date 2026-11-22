source "https://rubygems.org"

# Kerangka aplikasi web.
gem "rails", "~> 8.1.4", ">= 8.1.4.1"
gem "propshaft"
gem "puma", ">= 5.0"

# Penyimpanan data lokal tanpa server terpisah.
gem "sqlite3", ">= 2.1"

# Frontend ringan berbasis import map dan Hotwire.
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "jbuilder"

# Otentikasi kata sandi dan PIN petugas.
gem "bcrypt", "~> 3.1.7"

# Pembatasan laju permintaan untuk perlindungan servis.
gem "rack-attack"

# Pembuatan kode QR meja.
gem "rqrcode"

# Terjemahan pesan validasi dan tanggal bahasa Indonesia.
gem "rails-i18n"

# Zona waktu Asia/Jakarta di lingkungan Windows.
gem "tzinfo-data", platforms: %i[windows jruby]

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
end

group :development do
  gem "web-console"
end
