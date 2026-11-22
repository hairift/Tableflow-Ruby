# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_01_01_000000) do
  create_table "grup_varian", force: :cascade do |t|
    t.integer "produk_id", null: false
    t.string "nama", null: false
    t.boolean "wajib", default: false, null: false
    t.boolean "ganda", default: false, null: false
    t.integer "urutan", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["produk_id"], name: "index_grup_varian_on_produk_id"
  end

  create_table "item_pesanan", force: :cascade do |t|
    t.integer "pesanan_id", null: false
    t.integer "produk_id", null: false
    t.integer "jumlah", null: false
    t.decimal "harga_saat_pesan", precision: 14, null: false
    t.boolean "stok_dikurangi", default: false, null: false
    t.text "catatan"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pesanan_id"], name: "index_item_pesanan_on_pesanan_id"
    t.index ["produk_id"], name: "index_item_pesanan_on_produk_id"
  end

  create_table "kategori", force: :cascade do |t|
    t.string "nama", null: false
    t.integer "urutan", default: 0, null: false
    t.boolean "aktif", default: true, null: false
    t.integer "estimasi_menit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "kunci_api", force: :cascade do |t|
    t.string "nama", null: false
    t.string "hash_kunci", null: false
    t.string "akhir_kunci", null: false
    t.datetime "digunakan_pada"
    t.datetime "dicabut_pada"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hash_kunci"], name: "index_kunci_api_on_hash_kunci", unique: true
  end

  create_table "log_status_pesanan", force: :cascade do |t|
    t.integer "pesanan_id", null: false
    t.string "status_dari", null: false
    t.string "status_ke", null: false
    t.integer "diubah_oleh_id"
    t.text "catatan"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["diubah_oleh_id"], name: "index_log_status_pesanan_on_diubah_oleh_id"
    t.index ["pesanan_id"], name: "index_log_status_pesanan_on_pesanan_id"
  end

  create_table "meja", force: :cascade do |t|
    t.string "nomor_meja", null: false
    t.string "token_qr", null: false
    t.string "rahasia_token", null: false
    t.boolean "aktif", default: true, null: false
    t.integer "kapasitas", default: 4, null: false
    t.datetime "mulai_kunjungan_pada"
    t.boolean "tagihan_terbuka", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nomor_meja"], name: "index_meja_on_nomor_meja", unique: true
    t.index ["token_qr"], name: "index_meja_on_token_qr", unique: true
  end

  create_table "opsi_varian", force: :cascade do |t|
    t.integer "grup_id", null: false
    t.string "nama", null: false
    t.decimal "harga_tambahan", precision: 14, default: "0", null: false
    t.integer "urutan", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["grup_id"], name: "index_opsi_varian_on_grup_id"
  end

  create_table "panggilan_staf", force: :cascade do |t|
    t.integer "meja_id", null: false
    t.text "catatan"
    t.string "status", default: "menunggu", null: false
    t.datetime "diselesaikan_pada"
    t.integer "diselesaikan_oleh_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["diselesaikan_oleh_id"], name: "index_panggilan_staf_on_diselesaikan_oleh_id"
    t.index ["meja_id"], name: "index_panggilan_staf_on_meja_id"
    t.index ["status"], name: "index_panggilan_staf_on_status"
  end

  create_table "pelanggan", force: :cascade do |t|
    t.string "telepon", null: false
    t.string "nama"
    t.integer "poin", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["telepon"], name: "index_pelanggan_on_telepon", unique: true
  end

  create_table "pembayaran", force: :cascade do |t|
    t.integer "pesanan_id", null: false
    t.string "metode", null: false
    t.decimal "jumlah", precision: 14, null: false
    t.decimal "uang_diterima", precision: 14
    t.string "bukti_file"
    t.integer "diverifikasi_oleh_id"
    t.datetime "diverifikasi_pada"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["diverifikasi_oleh_id"], name: "index_pembayaran_on_diverifikasi_oleh_id"
    t.index ["pesanan_id"], name: "index_pembayaran_on_pesanan_id", unique: true
  end

  create_table "pengaturan_toko", force: :cascade do |t|
    t.string "gambar_qris"
    t.string "nama_toko"
    t.string "alamat"
    t.string "telepon"
    t.decimal "persen_pajak", precision: 5, scale: 2, default: "0.0", null: false
    t.decimal "persen_biaya_layanan", precision: 5, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pengguna", force: :cascade do |t|
    t.string "username", null: false
    t.string "hash_kata_sandi", null: false
    t.string "hash_pin"
    t.string "peran", default: "kasir", null: false
    t.boolean "aktif", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "index_pengguna_on_username", unique: true
  end

  create_table "pesanan", force: :cascade do |t|
    t.string "kode_pesanan", null: false
    t.integer "meja_id"
    t.string "nama_pelanggan"
    t.integer "pelanggan_id"
    t.integer "poin_diperoleh", default: 0, null: false
    t.string "kunci_idempotensi"
    t.string "status", default: "menunggu", null: false
    t.string "metode", null: false
    t.decimal "total_harga", precision: 14, null: false
    t.integer "kode_unik"
    t.decimal "jumlah_diskon", precision: 14, default: "0", null: false
    t.string "alasan_diskon"
    t.decimal "jumlah_pajak", precision: 14, default: "0", null: false
    t.decimal "jumlah_biaya_layanan", precision: 14, default: "0", null: false
    t.text "catatan"
    t.decimal "jumlah_pengembalian", precision: 14
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_pesanan_on_created_at"
    t.index ["kode_pesanan"], name: "index_pesanan_on_kode_pesanan", unique: true
    t.index ["kunci_idempotensi"], name: "index_pesanan_on_kunci_idempotensi", unique: true
    t.index ["meja_id"], name: "index_pesanan_on_meja_id"
    t.index ["pelanggan_id"], name: "index_pesanan_on_pelanggan_id"
    t.index ["status"], name: "index_pesanan_on_status"
  end

  create_table "produk", force: :cascade do |t|
    t.integer "kategori_id", null: false
    t.string "nama", null: false
    t.decimal "harga", precision: 14, null: false
    t.decimal "harga_modal", precision: 14
    t.integer "stok", default: 0, null: false
    t.boolean "lacak_stok", default: false, null: false
    t.string "foto"
    t.boolean "tersedia", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kategori_id"], name: "index_produk_on_kategori_id"
  end

  create_table "reservasi", force: :cascade do |t|
    t.string "nama_pelanggan", null: false
    t.string "nama_acara"
    t.string "telepon"
    t.integer "jumlah_tamu", null: false
    t.datetime "tanggal_reservasi", null: false
    t.integer "meja_id"
    t.string "status", default: "menunggu", null: false
    t.text "catatan"
    t.decimal "jumlah_deposit", precision: 14, default: "0", null: false
    t.boolean "deposit_lunas", default: false, null: false
    t.string "metode_deposit"
    t.datetime "deposit_lunas_pada"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meja_id"], name: "index_reservasi_on_meja_id"
    t.index ["status"], name: "index_reservasi_on_status"
    t.index ["tanggal_reservasi"], name: "index_reservasi_on_tanggal_reservasi"
  end

  create_table "shift", force: :cascade do |t|
    t.integer "pengguna_id", null: false
    t.string "nama_staf"
    t.datetime "mulai_pada", null: false
    t.datetime "selesai_pada"
    t.decimal "kas_awal", precision: 14
    t.decimal "kas_hitung", precision: 14
    t.decimal "jumlah_gojek", precision: 14
    t.decimal "jumlah_grabfood", precision: 14
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pengguna_id"], name: "index_shift_on_pengguna_id"
  end

  create_table "tingkat_loyalitas", force: :cascade do |t|
    t.integer "min_poin", null: false
    t.decimal "persen_diskon", precision: 5, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["min_poin"], name: "index_tingkat_loyalitas_on_min_poin", unique: true
  end

  create_table "varian_item_pesanan", force: :cascade do |t|
    t.integer "item_pesanan_id", null: false
    t.string "nama_grup", null: false
    t.string "nama_opsi", null: false
    t.decimal "harga_tambahan", precision: 14, default: "0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_pesanan_id"], name: "index_varian_item_pesanan_on_item_pesanan_id"
  end

  create_table "webhook", force: :cascade do |t|
    t.string "url", null: false
    t.string "daftar_event", null: false
    t.string "rahasia", null: false
    t.boolean "aktif", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "grup_varian", "produk", on_delete: :cascade
  add_foreign_key "item_pesanan", "pesanan", on_delete: :cascade
  add_foreign_key "item_pesanan", "produk"
  add_foreign_key "log_status_pesanan", "pengguna", column: "diubah_oleh_id"
  add_foreign_key "log_status_pesanan", "pesanan", on_delete: :cascade
  add_foreign_key "opsi_varian", "grup_varian", column: "grup_id", on_delete: :cascade
  add_foreign_key "panggilan_staf", "meja", on_delete: :cascade
  add_foreign_key "panggilan_staf", "pengguna", column: "diselesaikan_oleh_id"
  add_foreign_key "pembayaran", "pengguna", column: "diverifikasi_oleh_id"
  add_foreign_key "pembayaran", "pesanan", on_delete: :cascade
  add_foreign_key "pesanan", "meja", on_delete: :restrict
  add_foreign_key "pesanan", "pelanggan", on_delete: :restrict
  add_foreign_key "produk", "kategori"
  add_foreign_key "reservasi", "meja", on_delete: :restrict
  add_foreign_key "shift", "pengguna"
  add_foreign_key "varian_item_pesanan", "item_pesanan", on_delete: :cascade
end
