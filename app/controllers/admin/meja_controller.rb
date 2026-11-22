# Pengelolaan meja, token QR, dan status tagihan kunjungan.
module Admin
  class MejaController < BaseController
    before_action :butuh_admin
    before_action :atur_meja, only: %i[show edit update destroy reset_token tagihan selesai_kunjungan qr]

    def index
      @meja = Meja.order(:nomor_meja)
    end

    def show; end

    def new
      @meja = Meja.new
    end

    def edit; end

    def create
      @meja = Meja.new(parameter_meja)
      if @meja.save
        redirect_to admin_meja_path(@meja), notice: "Meja ditambahkan."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @meja.update(parameter_meja)
        redirect_to admin_meja_path(@meja), notice: "Data meja diperbarui."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @meja.destroy
        redirect_to admin_meja_index_path, notice: "Meja dihapus."
      else
        redirect_to admin_meja_index_path, alert: "Meja memiliki riwayat pesanan sehingga tidak dapat dihapus."
      end
    end

    def reset_token
      @meja.reset_token_qr!
      redirect_to admin_meja_path(@meja), notice: "Token QR meja diperbarui."
    end

    def tagihan
      @meja.update!(tagihan_terbuka: !@meja.tagihan_terbuka?)
      redirect_to admin_meja_index_path, notice: "Status tagihan diperbarui."
    end

    def selesai_kunjungan
      @meja.update!(mulai_kunjungan_pada: nil, tagihan_terbuka: false)
      redirect_to admin_meja_index_path, notice: "Kunjungan ditutup."
    end

    # Kode QR dirender sebagai SVG agar tajam pada ukuran apa pun.
    def qr
      url = "#{request.base_url}/t/#{@meja.token_qr}"
      qrcode = RQRCode::QRCode.new(url)
      svg = qrcode.as_svg(module_size: 6, light: "#FFFFFF", dark: "#16232E")
      render plain: svg, content_type: "image/svg+xml"
    end

    private

    def atur_meja
      @meja = Meja.find(params[:id])
    end

    def parameter_meja
      params.require(:meja).permit(:nomor_meja, :kapasitas, :aktif)
    end
  end
end
