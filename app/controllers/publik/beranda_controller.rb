# Halaman pembuka yang menjelaskan alur pemesanan lewat kode QR.
module Publik
  class BerandaController < ApplicationController
    def index
      @meja = Meja.aktif.first
    end
  end
end
