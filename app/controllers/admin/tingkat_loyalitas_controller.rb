# Pengaturan ambang poin dan besaran diskon member.
module Admin
  class TingkatLoyalitasController < BaseController
    before_action :butuh_admin
    before_action :atur_tingkat, only: %i[edit update destroy]

    def index
      @tingkat = TingkatLoyalitas.terurut
    end

    def new
      @tingkat = TingkatLoyalitas.new
    end

    def edit; end

    def create
      @tingkat = TingkatLoyalitas.new(parameter_tingkat)
      if @tingkat.save
        redirect_to admin_tingkat_loyalitas_index_path, notice: "Tingkat loyalitas ditambahkan."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @tingkat.update(parameter_tingkat)
        redirect_to admin_tingkat_loyalitas_index_path, notice: "Tingkat loyalitas diperbarui."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @tingkat.destroy
      redirect_to admin_tingkat_loyalitas_index_path, notice: "Tingkat loyalitas dihapus."
    end

    private

    def atur_tingkat
      @tingkat = TingkatLoyalitas.find(params[:id])
    end

    def parameter_tingkat
      params.require(:tingkat_loyalitas).permit(:min_poin, :persen_diskon)
    end
  end
end
