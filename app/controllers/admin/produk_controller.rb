# Pengelolaan produk, varian, ketersediaan, dan stok.
module Admin
  class ProdukController < BaseController
    before_action :butuh_admin, except: %i[index stok]
    before_action :atur_produk, only: %i[show edit update destroy stok]

    def index
      @produk = Produk.includes(:kategori).order("kategori.urutan", :nama)
      @kategori = Kategori.terurut
    end

    def show; end

    def new
      @produk = Produk.new
      @produk.grup_varian.build
    end

    def edit; end

    def create
      @produk = Produk.new(parameter_produk)
      if @produk.save
        redirect_to admin_produk_path(@produk), notice: "Produk ditambahkan."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @produk.update(parameter_produk)
        redirect_to admin_produk_path(@produk), notice: "Produk diperbarui."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @produk.destroy
        redirect_to admin_produk_index_path, notice: "Produk dihapus."
      else
        redirect_to admin_produk_index_path, alert: "Produk memiliki riwayat pesanan."
      end
    end

    # Stok dapat diubah kasir tanpa membuka form lengkap produk.
    def stok
      @produk.update!(stok: params[:stok])
      redirect_to admin_produk_index_path, notice: "Stok diperbarui."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to admin_produk_index_path, alert: e.record.errors.full_messages.first
    end

    private

    def atur_produk
      @produk = Produk.includes(grup_varian: :opsi_varian).find(params[:id])
    end

    def parameter_produk
      params.require(:produk).permit(
        :kategori_id, :nama, :harga, :harga_modal, :stok, :lacak_stok, :tersedia, :foto,
        grup_varian_attributes: [:id, :nama, :wajib, :ganda, :urutan, :_destroy,
                                 { opsi_varian_attributes: [:id, :nama, :harga_tambahan, :urutan, :_destroy] }]
      )
    end
  end
end
