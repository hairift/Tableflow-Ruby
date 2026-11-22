# Alur pemesanan pelanggan: buat pesanan, cek status, dan unggah bukti QRIS.
module Publik
  class PesananController < ApplicationController
    def create
      meja = Tableflow::TokenMeja.verifikasi(params[:token] || params.dig(:pesanan, :token))
      return gagal("Token meja tidak valid.", status: :forbidden) if meja.blank?

      item = params[:item]
      return gagal("Keranjang masih kosong.") unless item.is_a?(Array) && item.any?

      daftar = item.map do |b|
        {
          produk_id: b[:produk_id] || b["produk_id"],
          jumlah: b[:jumlah] || b["jumlah"],
          opsi_varian_ids: b[:opsi_varian_ids] || b["opsi_varian_ids"] || [],
          catatan: b[:catatan] || b["catatan"]
        }
      end

      pesanan = Tableflow::PembuatPesanan.new(
        meja: meja,
        item_list: daftar,
        metode: params[:metode],
        catatan: params[:catatan],
        kunci_idempotensi: params[:kunci_idempotensi],
        telepon_pelanggan: params[:telepon_pelanggan]
      ).panggil

      render json: detail(pesanan), status: :created
    rescue Tableflow::PembuatPesanan::Gagal => e
      gagal(e.message)
    rescue ActiveRecord::RecordInvalid => e
      gagal(e.record.errors.full_messages.first)
    end

    def show
      pesanan = Pesanan.find_by(kode_pesanan: params[:kode])
      return gagal("Pesanan tidak ditemukan.", status: :not_found) if pesanan.blank?

      render json: detail(pesanan)
    end

    def bayar
      pesanan = Pesanan.find_by(kode_pesanan: params[:kode])
      return gagal("Pesanan tidak ditemukan.", status: :not_found) if pesanan.blank?
      return gagal("Pesanan ini tidak memakai QRIS.") unless pesanan.qris?
      return gagal("Pesanan sudah diproses.") unless pesanan.menunggu?

      berkas = params[:bukti]
      return gagal("Bukti pembayaran wajib diunggah.") unless Tableflow::Unggahan.gambar_valid?(berkas)

      nama = Tableflow::Unggahan.nama_aman(berkas.original_filename)
      path = Rails.root.join("public", "unggahan", nama)
      FileUtils.mkdir_p(File.dirname(path))
      File.binwrite(path, berkas.read)
      berkas.rewind

      pesanan.pembayaran.update!(bukti_file: nama)
      pesanan.update!(status: "menunggu_verifikasi")
      LogStatusPesanan.create!(
        pesanan: pesanan,
        status_dari: "menunggu",
        status_ke: "menunggu_verifikasi",
        catatan: "Bukti pembayaran diunggah pelanggan"
      )
      PengirimWebhook.kirim("pesanan.status_berubah", pesanan)
      render json: detail(pesanan.reload)
    end

    private

    def detail(pesanan)
      estimasi = pesanan.item_pesanan.first&.produk&.kategori&.estimasi_menit
      {
        kode_pesanan: pesanan.kode_pesanan,
        nomor_meja: pesanan.meja&.nomor_meja,
        nama_pelanggan: pesanan.nama_pelanggan,
        status: pesanan.status,
        metode: pesanan.metode,
        total_harga: pesanan.total_harga.to_i,
        poin_diperoleh: pesanan.poin_diperoleh,
        estimasi_menit: estimasi,
        bukti_file: pesanan.pembayaran&.bukti_file,
        dibuat_pada: pesanan.created_at,
        item: pesanan.item_pesanan.map do |item|
          {
            nama: item.produk.nama,
            jumlah: item.jumlah,
            harga_satuan: item.harga_saat_pesan.to_i,
            catatan: item.catatan,
            varian: item.varian_item_pesanan.map(&:nama_opsi)
          }
        end
      }
    end
  end
end
