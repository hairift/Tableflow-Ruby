# Membuat pesanan secara atomik: stok, salinan harga, poin, dan pembayaran.
module Tableflow
  class PembuatPesanan
    class Gagal < StandardError; end

    def initialize(meja:, item_list:, metode:, catatan: nil, kunci_idempotensi: nil, telepon_pelanggan: nil)
      @meja = meja
      @item_list = item_list
      @metode = metode
      @catatan = catatan
      @kunci_idempotensi = kunci_idempotensi
      @telepon_pelanggan = telepon_pelanggan
    end

    def panggil
      pasti_shift_aktif!
      return pesanan_lama if pesanan_lama

      hasil = ActiveRecord::Base.transaction do
        hitungan = KalkulatorTotal.hitung(
          item_list: @item_list,
          telepon_pelanggan: @telepon_pelanggan
        )
        pasti_ada_item!(hitungan)
        kurangi_stok!(hitungan[:baris])

        mulai_kunjungan_bila_perlu
        pelanggan = @telepon_pelanggan.present? ? Pelanggan.find_or_create_by!(telepon: @telepon_pelanggan) : nil

        pesanan = Pesanan.create!(
          kode_pesanan: KodePesanan.buat,
          meja: @meja,
          pelanggan: pelanggan,
          kunci_idempotensi: @kunci_idempotensi,
          metode: @metode,
          status: "menunggu",
          total_harga: hitungan[:total_harga],
          jumlah_diskon: hitungan[:jumlah_diskon],
          alasan_diskon: hitungan[:alasan_diskon],
          jumlah_pajak: hitungan[:jumlah_pajak],
          jumlah_biaya_layanan: hitungan[:jumlah_biaya_layanan],
          poin_diperoleh: hitungan[:poin_diperoleh],
          catatan: @catatan
        )

        buat_baris_pesanan(pesanan, hitungan[:baris])
        Pembayaran.create!(pesanan: pesanan, metode: @metode, jumlah: hitungan[:total_harga])
        catat_log(pesanan, "baru", "menunggu")
        pesanan
      end

      PengirimWebhook.kirim("pesanan.dibuat", hasil)
      hasil
    end

    private

    def pesanan_lama
      return nil if @kunci_idempotensi.blank?

      @pesanan_lama ||= Pesanan.find_by(kunci_idempotensi: @kunci_idempotensi)
    end

    def pasti_shift_aktif!
      raise Gagal, "Kafe sedang tutup. Silakan kembali nanti." unless Shift.berjalan.exists?
    end

    def pasti_ada_item!(hitungan)
      raise Gagal, "Menu tidak tersedia atau jumlah tidak valid." if hitungan[:baris].empty?
    end

    def kurangi_stok!(baris)
      baris.each do |b|
        next unless b[:produk].lacak_stok?

        produk = Produk.lock.find(b[:produk].id)
        raise Gagal, "Stok #{produk.nama} tidak mencukupi." if produk.stok < b[:jumlah]

        produk.update!(stok: produk.stok - b[:jumlah])
      end
    end

    def mulai_kunjungan_bila_perlu
      return if @meja.ada_kunjungan_aktif?

      @meja.update!(mulai_kunjungan_pada: Time.current, tagihan_terbuka: false)
    end

    def buat_baris_pesanan(pesanan, baris)
      baris.each do |b|
        item = ItemPesanan.create!(
          pesanan: pesanan,
          produk: b[:produk],
          jumlah: b[:jumlah],
          harga_saat_pesan: b[:harga_satuan],
          catatan: b[:catatan],
          stok_dikurangi: b[:produk].lacak_stok?
        )

        b[:opsi_ids].each do |id|
          opsi = OpsiVarian.find_by(id: id)
          next if opsi.blank?

          VarianItemPesanan.create!(
            item_pesanan: item,
            nama_grup: opsi.grup.nama,
            nama_opsi: opsi.nama,
            harga_tambahan: opsi.harga_tambahan
          )
        end
      end
    end

    def catat_log(pesanan, dari, ke, petugas: nil, catatan: nil)
      LogStatusPesanan.create!(
        pesanan: pesanan,
        status_dari: dari,
        status_ke: ke,
        diubah_oleh: petugas,
        catatan: catatan
      )
    end
  end
end
