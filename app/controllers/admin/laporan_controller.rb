# Laporan pendapatan dan ekspor ringkasan ke format CSV.
module Admin
  class LaporanController < BaseController
    before_action :butuh_admin

    def index
      dari = params[:dari].presence&.to_date || Tableflow::Waktu.sekarang.to_date
      sampai = params[:sampai].presence&.to_date || Tableflow::Waktu.sekarang.to_date
      @dari = dari
      @sampai = sampai
      @ringkasan = Tableflow::Laporan.ringkasan(dari: dari, sampai: sampai)
    end

    def ekspor
      dari = params[:dari].to_date
      sampai = params[:sampai].to_date
      ringkasan = Tableflow::Laporan.ringkasan(dari: dari, sampai: sampai)
      return redirect_to admin_laporan_index_path, alert: ringkasan[:error] if ringkasan[:error]

      csv = CSV.generate do |baris|
        baris << %w[Laporan Tableflow-Scan]
        baris << ["Dari", dari.to_s, "Sampai", sampai.to_s]
        baris << []
        baris << ["Jumlah pesanan", ringkasan[:jumlah_pesanan]]
        baris << ["Total pendapatan", ringkasan[:total_pendapatan]]
        baris << []
        baris << %w[Produk Terjual Total]
        ringkasan[:produk_terlaris].each { |p| baris << [p[:nama], p[:jumlah], p[:total]] }
      end
      send_data csv, filename: "laporan-#{dari}-#{sampai}.csv", type: "text/csv"
    rescue Date::Error
      redirect_to admin_laporan_index_path, alert: "Tanggal tidak valid."
    end
  end
end
