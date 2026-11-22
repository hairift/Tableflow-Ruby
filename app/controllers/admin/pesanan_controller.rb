# Pengelolaan pesanan, konfirmasi pembayaran, dan pembatalan.
module Admin
  class PesananController < BaseController
    before_action :butuh_admin, only: %i[log_aktivitas batalkan manual]

    def index
      @status = params[:status].presence_in(Pesanan::STATUS)
      @pesanan = Pesanan.includes(:meja, :pelanggan, item_pesanan: :produk)
                        .then { |relasi| @status ? relasi.where(status: @status) : relasi }
                        .terbaru
    end

    def show
      @pesanan = Pesanan.includes(item_pesanan: %i[produk varian_item_pesanan]).find(params[:id])
    end

    def log_aktivitas
      @log = LogStatusPesanan.includes(:pesanan, :diubah_oleh).terbaru.limit(200)
    end

    def konfirmasi_bayar
      hasil = Tableflow::PengelolaPesanan.konfirmasi_bayar(
        pesanan: pesanan,
        petugas: petugas_saat_ini,
        uang_diterima: params[:uang_diterima]
      )
      redirect_to admin_pesanan_path(hasil), notice: "Pembayaran dikonfirmasi."
    rescue Tableflow::PengelolaPesanan::Gagal => e
      redirect_to admin_pesanan_path(pesanan), alert: e.message
    end

    # Verifikasi akhir bukti QRIS setelah diperiksa kasir.
    def verifikasi_qris
      hasil = Tableflow::PengelolaPesanan.verifikasi_qris(pesanan: pesanan, petugas: petugas_saat_ini)
      redirect_to admin_pesanan_path(hasil), notice: "Bukti QRIS terverifikasi."
    rescue Tableflow::PengelolaPesanan::Gagal => e
      redirect_to admin_pesanan_path(pesanan), alert: e.message
    end

    def ubah_status
      hasil = Tableflow::PengelolaPesanan.ubah_status(
        pesanan,
        params[:status_baru],
        petugas_saat_ini,
        params[:catatan]
      )
      redirect_to admin_pesanan_path(hasil), notice: "Status diperbarui menjadi #{hasil.status}."
    rescue Tableflow::PengelolaPesanan::Gagal => e
      redirect_to admin_pesanan_path(pesanan), alert: e.message
    end

    def batalkan
      Tableflow::PengelolaPesanan.batalkan(
        pesanan: pesanan,
        petugas: petugas_saat_ini,
        alasan: params[:alasan],
        pin: params[:pin],
        jumlah_pengembalian: params[:jumlah_pengembalian] || 0
      )
      redirect_to admin_pesanan_path(pesanan), notice: "Pesanan dibatalkan."
    rescue Tableflow::PengelolaPesanan::Gagal => e
      redirect_to admin_pesanan_path(pesanan), alert: e.message
    end

    def manual_form
      @produk = Produk.tersedia.order(:nama)
      @pelanggan = Pelanggan.order(:nama)
    end

    # Pesanan manual/takeaway dibuat petugas dengan harga yang dihitung server.
    def manual
      item = params[:item]
      item = item.values if item.is_a?(ActionController::Parameters)
      return redirect_to admin_pesanan_path, alert: "Keranjang kosong." unless item.is_a?(Array) && item.any?

      daftar = item.map do |b|
        {
          produk_id: b[:produk_id] || b["produk_id"],
          jumlah: b[:jumlah] || b["jumlah"],
          opsi_varian_ids: b[:opsi_varian_ids] || b["opsi_varian_ids"] || [],
          catatan: b[:catatan] || b["catatan"]
        }
      end
      hitungan = Tableflow::KalkulatorTotal.hitung(
        item_list: daftar,
        telepon_pelanggan: params[:telepon_pelanggan]
      )
      diskon = params[:jumlah_diskon].to_i
      diskon = [diskon, hitungan[:subtotal]].min

      pesanan = Pesanan.create!(
        kode_pesanan: Tableflow::KodePesanan.buat,
        nama_pelanggan: params[:nama_pelanggan],
        pelanggan: params[:telepon_pelanggan].present? ? Pelanggan.find_or_create_by!(telepon: params[:telepon_pelanggan]) : nil,
        metode: params[:metode],
        status: "menunggu",
        total_harga: hitungan[:total_harga] - diskon,
        jumlah_diskon: hitungan[:jumlah_diskon] + diskon,
        alasan_diskon: params[:alasan_diskon],
        jumlah_pajak: hitungan[:jumlah_pajak],
        jumlah_biaya_layanan: hitungan[:jumlah_biaya_layanan],
        poin_diperoleh: hitungan[:poin_diperoleh],
        catatan: params[:catatan]
      )
      hitungan[:baris].each do |b|
        ItemPesanan.create!(pesanan: pesanan, produk: b[:produk], jumlah: b[:jumlah],
                            harga_saat_pesan: b[:harga_satuan], catatan: b[:catatan])
      end
      Pembayaran.create!(pesanan: pesanan, metode: params[:metode], jumlah: pesanan.total_harga)
      LogStatusPesanan.create!(pesanan: pesanan, status_dari: "baru", status_ke: "menunggu",
                               diubah_oleh: petugas_saat_ini)
      redirect_to admin_pesanan_path(pesanan), notice: "Pesanan manual dibuat."
    end

    private

    def pesanan
      @pesanan ||= Pesanan.find(params[:id])
    end
  end
end
