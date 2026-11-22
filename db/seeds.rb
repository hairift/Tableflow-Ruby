# Data awal untuk pengembangan dan unjuk rasa tampilan.
# Jalankan dengan: rails db:seed
# Seluruh data di sini hanya dipakai di lingkungan development.

puts "Menyiapkan pengaturan toko..."
pengaturan = PengaturanToko.saat_ini
pengaturan.update!(
  nama_toko: "Kopi Legacy",
  alamat: "Jalan Raya Darmo No. 12, Surabaya",
  telepon: "031-5550123",
  persen_pajak: 0,
  persen_biaya_layanan: 0
)

puts "Membuat akun petugas..."
unless Pengguna.exists?(username: "admin")
  Pengguna.create!(
    username: "admin",
    kata_sandi: "Tableflow2026!",
    pin: "246810",
    peran: "admin"
  )
end
unless Pengguna.exists?(username: "kasir")
  Pengguna.create!(
    username: "kasir",
    kata_sandi: "Tableflow2026!",
    peran: "kasir"
  )
end

puts "Membuat meja..."
1.upto(8) do |nomor|
  Meja.find_or_create_by!(nomor_meja: format("%02d", nomor)) do |meja|
    meja.kapasitas = nomor <= 4 ? 4 : 6
  end
end

puts "Membuat kategori dan produk..."
menu = {
  "Kopi" => [
    ["Kopi Susu Gula Aren", 18000, 7000, "kopi-susu-gula-aren.jpg", [["Panas", 0], ["Dingin", 0], ["Extra Shot", 5000]]],
    ["Americano", 15000, 5000, "americano.jpg", [["Panas", 0], ["Dingin", 0]]],
    ["Flat White", 22000, 8000, "flat-white.jpg", [["Panas", 0], ["Dingin", 0], ["Oat Milk", 4000]]]
  ],
  "Minuman" => [
    ["Teh Tarik Hangat", 12000, 4000, "teh-tarik-hangat.jpg", [["Panas", 0], ["Dingin", 0]]],
    ["Lemon Tea", 11000, 3500, "lemon-tea.jpg", [["Panas", 0], ["Dingin", 0], ["Extra Lemon", 2000]]],
    ["Air Mineral", 5000, 2000, "air-mineral.jpg", []]
  ],
  "Makanan" => [
    ["Roti Bakar Keju", 16000, 6000, "roti-bakar-keju.jpg", [["Keju", 0], ["Cokelat", 0], ["Extra Keju", 3000]]],
    ["Nasi Goreng Spesial", 28000, 12000, "nasi-goreng-spesial.jpg", [["Pedas", 0], ["Tidak Pedas", 0], ["Extra Telur", 4000]]],
    ["Croissant", 14000, 5000, "croissant.jpg", []]
  ]
}

menu.each_with_index do |(nama_kategori, daftar), indeks|
  kategori = Kategori.find_or_create_by!(nama: nama_kategori) do |catat|
    catat.urutan = indeks
    catat.estimasi_menit = nama_kategori == "Makanan" ? 15 : 7
  end

  daftar.each do |nama, harga, modal, foto, pilihan|
    produk = Produk.find_or_create_by!(nama: nama, kategori: kategori) do |catat|
      catat.harga = harga
      catat.harga_modal = modal
      catat.stok = 50
      catat.lacak_stok = false
      catat.tersedia = true
    end
    produk.update!(foto: foto) unless produk.foto == foto

    next if produk.grup_varian.exists? || pilihan.empty?

    grup = produk.grup_varian.create!(nama: "Pilihan", urutan: 0, wajib: true, ganda: false)
    pilihan.each_with_index do |(nama_opsi, tambahan), urutan|
      grup.opsi_varian.create!(nama: nama_opsi, harga_tambahan: tambahan, urutan: urutan)
    end
  end
end

puts "Membuat tingkat loyalitas..."
[[100, 5], [300, 10], [600, 15]].each do |poin, diskon|
  TingkatLoyalitas.find_or_create_by!(min_poin: poin) { |t| t.persen_diskon = diskon }
end

puts "Membuat shift aktif..."
unless Shift.berjalan.exists?
  Shift.create!(
    pengguna: Pengguna.find_by!(username: "admin"),
    nama_staf: "Riana",
    kas_awal: 200000,
    mulai_pada: Time.current
  )
end

puts "Selesai. Akun admin: admin / Tableflow2026! (PIN 246810)"
