Rails.application.routes.draw do
  # Pemeriksaan kesehatan untuk pemantau layanan.
  get "up" => "rails/health#show", as: :pemeriksaan_kesehatan

  # Halaman pembuka: pengunjung diarahkan ke pintu masuk pelanggan.
  root "publik/beranda#index"

  # Rute publik dipasang tanpa sesi agar pengunjung anonim tidak membuat sesi.
  scope "api/publik", defaults: { format: :json } do
    get "menu", to: "publik/menu#index"
    get "pengaturan", to: "publik/pengaturan#index"
    get "gambar-qris/:nama", to: "publik/pengaturan#gambar_qris"
    get "foto-produk/:nama", to: "publik/pengaturan#foto_produk"
    post "keranjang/total", to: "publik/keranjang#total"
    post "pesanan", to: "publik/pesanan#create"
    get "pesanan/:kode", to: "publik/pesanan#show"
    post "pesanan/:kode/bayar", to: "publik/pesanan#bayar"
    post "panggilan-staf", to: "publik/panggilan_staf#create"
    get "meja/:token/tagihan", to: "publik/meja#tagihan"
  end

  # Pintu masuk pelanggan memakai token QR meja.
  get "t/:token", to: "publik/meja#tampil", as: :meja_publik

  # Otentikasi petugas.
  get "masuk", to: "sesi#new", as: :halaman_masuk
  post "masuk", to: "sesi#create"
  delete "keluar", to: "sesi#destroy", as: :keluar

  # Panel operasional.
  namespace :admin, path: "panel" do
    get "dashboard", to: "dashboard#index", as: :dashboard

    resources :pesanan, only: %i[index show] do
      collection do
        get "log-aktivitas", to: "pesanan#log_aktivitas"
        get "manual", to: "pesanan#manual_form"
        post "manual", to: "pesanan#manual"
      end
      member do
        patch "konfirmasi-bayar", to: "pesanan#konfirmasi_bayar"
        patch "verifikasi-qris", to: "pesanan#verifikasi_qris"
        patch "status", to: "pesanan#ubah_status"
        patch "batalkan", to: "pesanan#batalkan"
      end
    end

    resources :meja do
      member do
        post "reset-token", to: "meja#reset_token"
        patch "tagihan", to: "meja#tagihan"
        patch "selesai-kunjungan", to: "meja#selesai_kunjungan"
        get "qr", to: "meja#qr"
      end
    end

    resources :kategori
    resources :produk do
      member do
        patch "stok", to: "produk#stok"
      end
    end
    resources :panggilan_staf, only: %i[index update]
    resources :reservasi
    resources :pelanggan, only: %i[index show]
    resources :tingkat_loyalitas, except: %i[show]
    resources :shift, only: %i[index create update] do
      collection do
        patch "selesai", to: "shift#selesai"
      end
    end
    resources :pengguna, except: %i[show]
    resources :laporan, only: %i[index] do
      collection do
        get "ekspor", to: "laporan#ekspor"
      end
    end
    get "pengaturan", to: "pengaturan#edit", as: :pengaturan
    patch "pengaturan", to: "pengaturan#update"
    resources :kunci_api, except: %i[show new edit update]
    resources :webhook, except: %i[show new edit update]
  end

  # API eksternal berbasis kunci (akses baca saja).
  namespace :eksternal, path: "api/eksternal/v1", defaults: { format: :json } do
    get "pesanan", to: "pesanan#index"
    get "produk", to: "produk#index"
  end
end
