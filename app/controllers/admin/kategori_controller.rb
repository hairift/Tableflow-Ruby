# Pengelolaan kategori menu.
module Admin
  class KategoriController < BaseController
    before_action :butuh_admin
    before_action :atur_kategori, only: %i[show edit update destroy]

    def index
      @kategori = Kategori.terurut
    end

    def show; end

    def new
      @kategori = Kategori.new
    end

    def edit; end

    def create
      @kategori = Kategori.new(parameter_kategori)
      if @kategori.save
        redirect_to admin_kategori_index_path, notice: "Kategori ditambahkan."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @kategori.update(parameter_kategori)
        redirect_to admin_kategori_index_path, notice: "Kategori diperbarui."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @kategori.destroy
        redirect_to admin_kategori_index_path, notice: "Kategori dihapus."
      else
        redirect_to admin_kategori_index_path, alert: "Kategori masih memiliki produk."
      end
    end

    private

    def atur_kategori
      @kategori = Kategori.find(params[:id])
    end

    def parameter_kategori
      params.require(:kategori).permit(:nama, :urutan, :aktif, :estimasi_menit)
    end
  end
end
