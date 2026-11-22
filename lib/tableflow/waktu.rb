# Pembatasan hari memakai zona waktu Asia/Jakarta secara eksplisit.
module Tableflow
  module Waktu
    ZONA = "Asia/Jakarta"
    OFSET = 7 * 60 * 60

    def self.sekarang
      Time.current.in_time_zone(ZONA)
    end

    def self.awal_hari(waktu = sekarang)
      waktu.in_time_zone(ZONA).beginning_of_day
    end

    def self.akhir_hari(waktu = sekarang)
      waktu.in_time_zone(ZONA).end_of_day
    end

    def self.rentang_hari(waktu = sekarang)
      awal_hari(waktu)..akhir_hari(waktu)
    end
  end
end
