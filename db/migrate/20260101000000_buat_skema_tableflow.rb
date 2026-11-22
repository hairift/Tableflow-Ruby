# Skema awal Tableflow-Scan.
# Seluruh nama tabel dan kolom memakai bahasa Indonesia agar konsisten dengan kode aplikasi.
class BuatSkemaTableflow < ActiveRecord::Migration[8.1]
  def change
    create_table :meja do |t|
      t.string :nomor_meja, null: false
      t.string :token_qr, null: false
      t.string :rahasia_token, null: false
      t.boolean :aktif, null: false, default: true
      t.integer :kapasitas, null: false, default: 4
      t.datetime :mulai_kunjungan_pada
      t.boolean :tagihan_terbuka, null: false, default: false
      t.timestamps
    end
    add_index :meja, :nomor_meja, unique: true
    add_index :meja, :token_qr, unique: true

    create_table :pengaturan_toko do |t|
      t.string :gambar_qris
      t.string :nama_toko
      t.string :alamat
      t.string :telepon
      t.decimal :persen_pajak, precision: 5, scale: 2, null: false, default: 0
      t.decimal :persen_biaya_layanan, precision: 5, scale: 2, null: false, default: 0
      t.timestamps
    end

    create_table :pengguna do |t|
      t.string :username, null: false
      t.string :hash_kata_sandi, null: false
      t.string :hash_pin
      t.string :peran, null: false, default: "kasir"
      t.boolean :aktif, null: false, default: true
      t.timestamps
    end
    add_index :pengguna, :username, unique: true

    create_table :kategori do |t|
      t.string :nama, null: false
      t.integer :urutan, null: false, default: 0
      t.boolean :aktif, null: false, default: true
      t.integer :estimasi_menit
      t.timestamps
    end

    create_table :produk do |t|
      t.references :kategori, null: false, foreign_key: { to_table: :kategori }
      t.string :nama, null: false
      t.decimal :harga, precision: 14, scale: 0, null: false
      t.decimal :harga_modal, precision: 14, scale: 0
      t.integer :stok, null: false, default: 0
      t.boolean :lacak_stok, null: false, default: false
      t.string :foto
      t.boolean :tersedia, null: false, default: true
      t.timestamps
    end

    create_table :grup_varian do |t|
      t.references :produk, null: false, foreign_key: { to_table: :produk, on_delete: :cascade }
      t.string :nama, null: false
      t.boolean :wajib, null: false, default: false
      t.boolean :ganda, null: false, default: false
      t.integer :urutan, null: false, default: 0
      t.timestamps
    end

    create_table :opsi_varian do |t|
      t.references :grup, null: false, foreign_key: { to_table: :grup_varian, on_delete: :cascade }
      t.string :nama, null: false
      t.decimal :harga_tambahan, precision: 14, scale: 0, null: false, default: 0
      t.integer :urutan, null: false, default: 0
      t.timestamps
    end

    create_table :pelanggan do |t|
      t.string :telepon, null: false
      t.string :nama
      t.integer :poin, null: false, default: 0
      t.timestamps
    end
    add_index :pelanggan, :telepon, unique: true

    create_table :tingkat_loyalitas do |t|
      t.integer :min_poin, null: false
      t.decimal :persen_diskon, precision: 5, scale: 2, null: false
      t.timestamps
    end
    add_index :tingkat_loyalitas, :min_poin, unique: true

    create_table :shift do |t|
      t.references :pengguna, null: false, foreign_key: { to_table: :pengguna }
      t.string :nama_staf
      t.datetime :mulai_pada, null: false
      t.datetime :selesai_pada
      t.decimal :kas_awal, precision: 14, scale: 0
      t.decimal :kas_hitung, precision: 14, scale: 0
      t.decimal :jumlah_gojek, precision: 14, scale: 0
      t.decimal :jumlah_grabfood, precision: 14, scale: 0
      t.timestamps
    end

    create_table :pesanan do |t|
      t.string :kode_pesanan, null: false
      t.references :meja, foreign_key: { to_table: :meja, on_delete: :restrict }
      t.string :nama_pelanggan
      t.references :pelanggan, foreign_key: { to_table: :pelanggan, on_delete: :restrict }
      t.integer :poin_diperoleh, null: false, default: 0
      t.string :kunci_idempotensi
      t.string :status, null: false, default: "menunggu"
      t.string :metode, null: false
      t.decimal :total_harga, precision: 14, scale: 0, null: false
      t.integer :kode_unik
      t.decimal :jumlah_diskon, precision: 14, scale: 0, null: false, default: 0
      t.string :alasan_diskon
      t.decimal :jumlah_pajak, precision: 14, scale: 0, null: false, default: 0
      t.decimal :jumlah_biaya_layanan, precision: 14, scale: 0, null: false, default: 0
      t.text :catatan
      t.decimal :jumlah_pengembalian, precision: 14, scale: 0
      t.timestamps
    end
    add_index :pesanan, :kode_pesanan, unique: true
    add_index :pesanan, :kunci_idempotensi, unique: true
    add_index :pesanan, :status
    add_index :pesanan, :created_at

    create_table :item_pesanan do |t|
      t.references :pesanan, null: false, foreign_key: { to_table: :pesanan, on_delete: :cascade }
      t.references :produk, null: false, foreign_key: { to_table: :produk }
      t.integer :jumlah, null: false
      t.decimal :harga_saat_pesan, precision: 14, scale: 0, null: false
      t.boolean :stok_dikurangi, null: false, default: false
      t.text :catatan
      t.timestamps
    end

    create_table :varian_item_pesanan do |t|
      t.references :item_pesanan, null: false, foreign_key: { to_table: :item_pesanan, on_delete: :cascade }
      t.string :nama_grup, null: false
      t.string :nama_opsi, null: false
      t.decimal :harga_tambahan, precision: 14, scale: 0, null: false, default: 0
      t.timestamps
    end

    create_table :pembayaran do |t|
      t.references :pesanan, null: false, foreign_key: { to_table: :pesanan, on_delete: :cascade }, index: { unique: true }
      t.string :metode, null: false
      t.decimal :jumlah, precision: 14, scale: 0, null: false
      t.decimal :uang_diterima, precision: 14, scale: 0
      t.string :bukti_file
      t.references :diverifikasi_oleh, foreign_key: { to_table: :pengguna }
      t.datetime :diverifikasi_pada
      t.timestamps
    end

    create_table :log_status_pesanan do |t|
      t.references :pesanan, null: false, foreign_key: { to_table: :pesanan, on_delete: :cascade }
      t.string :status_dari, null: false
      t.string :status_ke, null: false
      t.references :diubah_oleh, foreign_key: { to_table: :pengguna }
      t.text :catatan
      t.timestamps
    end

    create_table :panggilan_staf do |t|
      t.references :meja, null: false, foreign_key: { to_table: :meja, on_delete: :cascade }
      t.text :catatan
      t.string :status, null: false, default: "menunggu"
      t.datetime :diselesaikan_pada
      t.references :diselesaikan_oleh, foreign_key: { to_table: :pengguna }
      t.timestamps
    end
    add_index :panggilan_staf, :status

    create_table :reservasi do |t|
      t.string :nama_pelanggan, null: false
      t.string :nama_acara
      t.string :telepon
      t.integer :jumlah_tamu, null: false
      t.datetime :tanggal_reservasi, null: false
      t.references :meja, foreign_key: { to_table: :meja, on_delete: :restrict }
      t.string :status, null: false, default: "menunggu"
      t.text :catatan
      t.decimal :jumlah_deposit, precision: 14, scale: 0, null: false, default: 0
      t.boolean :deposit_lunas, null: false, default: false
      t.string :metode_deposit
      t.datetime :deposit_lunas_pada
      t.timestamps
    end
    add_index :reservasi, :status
    add_index :reservasi, :tanggal_reservasi

    create_table :kunci_api do |t|
      t.string :nama, null: false
      t.string :hash_kunci, null: false
      t.string :akhir_kunci, null: false
      t.datetime :digunakan_pada
      t.datetime :dicabut_pada
      t.timestamps
    end
    add_index :kunci_api, :hash_kunci, unique: true

    create_table :webhook do |t|
      t.string :url, null: false
      t.string :daftar_event, null: false
      t.string :rahasia, null: false
      t.boolean :aktif, null: false, default: true
      t.timestamps
    end
  end
end
