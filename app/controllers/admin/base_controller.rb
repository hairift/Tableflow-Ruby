# Induk pengontrol panel administrasi yang mewajibkan sesi petugas.
module Admin
  class BaseController < ApplicationController
    before_action :butuh_petugas
  end
end
