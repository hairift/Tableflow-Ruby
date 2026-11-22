# Pengaturan identitas toko, pajak, biaya layanan, dan gambar QRIS statis.
module Admin
  class PengaturanController < BaseController
    before_action :butuh_admin

    def edit
      @pengaturan = PengaturanToko.saat_ini
    end

    def update
      @pengaturan = PengaturanToko.saat_ini

      if params[:gambar_qris].present?
        hasil = simpan_qris
        return redirect_to admin_pengaturan_path, notice: "Gambar QRIS diperbarui." if hasil

        return redirect_to admin_pengaturan_path, alert: "Berkas QRIS harus berupa PNG, JPG, atau WebP maksimal 2 MB."
      end

      if @pengaturan.update(parameter_pengaturan)
        redirect_to admin_pengaturan_path, notice: "Pengaturan disimpan."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def simpan_qris
      berkas = params[:gambar_qris]
      return false unless Tableflow::Unggahan.gambar_valid?(berkas)

      nama = Tableflow::Unggahan.nama_aman(berkas.original_filename)
      path = Rails.root.join("public", "unggahan", nama)
      FileUtils.mkdir_p(File.dirname(path))
      File.binwrite(path, berkas.read)
      @pengaturan.update_column(:gambar_qris, nama)
      true
    end

    def parameter_pengaturan
      params.require(:pengaturan_toko).permit(:nama_toko, :alamat, :telepon, :persen_pajak, :persen_biaya_layanan)
    end
  end
end
