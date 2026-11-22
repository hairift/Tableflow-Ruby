# Ikon vektor berbasis jalur SVG. Seluruh ikon memakai garis, bukan emoji.
module IkonHelper
  JALUR = {
    "pindai" => '<path d="M3 7V5a2 2 0 0 1 2-2h2M17 3h2a2 2 0 0 1 2 2v2M21 17v2a2 2 0 0 1-2 2h-6M3 17v2a2 2 0 0 0 2 2h2M7 12h10"/>',
    "menu" => '<path d="M4 6h16M4 12h16M4 18h16"/>',
    "keranjang" => '<path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4zM3 6h18M16 10a4 4 0 0 1-8 0"/>',
    "centang" => '<path d="M20 6 9 17l-5-5"/>',
    "tutup" => '<path d="M18 6 6 18M6 6l12 12"/>',
    "jam" => '<circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/>',
    "pengguna" => '<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"/>',
    "pengaturan" => '<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 0 0 .34 1.88l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.7 1.7 0 0 0-1.88-.34 1.7 1.7 0 0 0-1 1.55V21a2 2 0 1 1-4 0v-.09A1.7 1.7 0 0 0 9 19.4a1.7 1.7 0 0 0-1.88.34l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06A1.7 1.7 0 0 0 4.63 15a1.7 1.7 0 0 0-1.55-1H3a2 2 0 1 1 0-4h.09A1.7 1.7 0 0 0 4.63 9a1.7 1.7 0 0 0-.34-1.88l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06A1.7 1.7 0 0 0 9 4.63a1.7 1.7 0 0 0 1-1.55V3a2 2 0 1 1 4 0v.09a1.7 1.7 0 0 0 1 1.55 1.7 1.7 0 0 0 1.88-.34l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06A1.7 1.7 0 0 0 19.4 9v.02a1.7 1.7 0 0 0 1.55 1H21a2 2 0 1 1 0 4h-.09a1.7 1.7 0 0 0-1.51 1z"/>',
    "keluar" => '<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9"/>',
    "tambah" => '<path d="M12 5v14M5 12h14"/>',
    "kurang" => '<path d="M5 12h14"/>',
    "sunting" => '<path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4z"/>',
    "hapus" => '<path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2M10 11v6M14 11v6"/>',
    "cari" => '<circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/>',
    "grafik" => '<path d="M3 3v18h18M18 17V9M13 17V5M8 17v-3"/>',
    "struk" => '<path d="M4 2v20l2-1 2 1 2-1 2 1 2-1 2 1 2-1 2 1V2l-2 1-2-1-2 1-2-1-2 1-2-1-2 1zM8 7h8M8 11h8M8 15h5"/>',
    "kode-qr" => '<path d="M3 3h7v7H3zM14 3h7v7h-7zM3 14h7v7H3z"/><path d="M14 14h3v3h-3zM19 14h2v2h-2zM14 19h3v2h-3zM19 19h2v2h-2z"/>',
    "lonceng" => '<path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9M13.7 21a2 2 0 0 1-3.4 0"/>',
    "kanan" => '<path d="M5 12h14M13 6l6 6-6 6"/>',
    "kiri" => '<path d="M19 12H5M11 18l-6-6 6-6"/>',
    "mata" => '<path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7z"/><circle cx="12" cy="12" r="3"/>',
    "telepon" => '<path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6A19.79 19.79 0 0 1 2.12 4.3 2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.13.96.36 1.9.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.91.34 1.85.57 2.81.7A2 2 0 0 1 22 16.92z"/>',
    "kalender" => '<rect x="3" y="4" width="18" height="18" rx="2"/><path d="M16 2v4M8 2v4M3 10h18"/>',
    "uang" => '<rect x="2" y="6" width="20" height="12" rx="2"/><circle cx="12" cy="12" r="2"/><path d="M6 12h.01M18 12h.01"/>',
    "perisai" => '<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>',
    "peringatan" => '<path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3zM12 9v4M12 17h.01"/>',
    "info" => '<circle cx="12" cy="12" r="10"/><path d="M12 16v-4M12 8h.01"/>',
    "bawah" => '<path d="m6 9 6 6 6-6"/>',
    "unduh" => '<path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3"/>',
    "segarkan" => '<path d="M21 2v6h-6M3 22v-6h6M21 8a9 9 0 0 0-15.5-3.5L3 8M3 16a9 9 0 0 0 15.5 3.5L21 16"/>',
    "kunci" => '<rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/>',
    "kunci-api" => '<circle cx="7.5" cy="15.5" r="5.5"/><path d="m21 2-9.6 9.6M15.5 7.5l3 3L22 7l-3-3"/>',
    "rumah" => '<path d="m3 10 9-7 9 7v10a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2zM9 22V12h6v10"/>',
    "toko" => '<path d="m2 7 2-4h16l2 4M4 7v13a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1V7M2 7h20M9 21v-6h6v6"/>',
    "label" => '<path d="M20.59 13.41 13.42 20.58a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82zM7 7h.01"/>',
    "lapisan" => '<path d="m12 2 9 5-9 5-9-5 9-5zM3 12l9 5 9-5M3 17l9 5 9-5"/>',
    "kopi" => '<path d="M18 8h1a4 4 0 0 1 0 8h-1M2 8h16v9a4 4 0 0 1-4 4H6a4 4 0 0 1-4-4zM6 1v4M10 1v4M14 1v4"/>',
    "peralatan" => '<path d="M3 2v7a2 2 0 0 0 2 2h4a2 2 0 0 0 2-2V2M7 2v20M21 15V2a5 5 0 0 0-5 5v6a2 2 0 0 0 2 2h3zM18 15v7"/>',
    "paket" => '<path d="m7.5 4.27 9 5.15M21 8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16zM3.3 7 12 12l8.7-5M12 22V12"/>',
    "aktivitas" => '<path d="M22 12h-4l-3 9L9 3l-3 9H2"/>',
    "dokumen" => '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8zM14 2v6h6M16 13H8M16 17H8M10 9H8"/>',
    "tautan" => '<path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/>',
    "centang-lingkar" => '<circle cx="12" cy="12" r="10"/><path d="m8 12 3 3 5-6"/>',
    "bantuan" => '<circle cx="12" cy="12" r="10"/><path d="M9.1 9a3 3 0 0 1 5.8 1c0 2-3 3-3 3M12 17h.01"/>',
    "lokasi" => '<path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0z"/><circle cx="12" cy="10" r="3"/>',
    "dompet" => '<path d="M20 12V8H6a2 2 0 0 1-2-2c0-1.1.9-2 2-2h12v4M4 6v12c0 1.1.9 2 2 2h14v-4M18 12a2 2 0 0 0 0 4h4v-4z"/>',
    "koki" => '<path d="M17 21a1 1 0 0 0 1-1v-5a4 4 0 0 0-3-3.87M6 21a1 1 0 0 1-1-1v-5a4 4 0 0 1 3-3.87M6 11a4 4 0 0 1 0-8 4 4 0 0 1 8 0 4 4 0 0 1 4 8M6 21h12"/>',
    "kirim" => '<path d="m22 2-7 20-4-9-9-4zM22 2 11 13"/>',
    "titik" => '<circle cx="5" cy="12" r="1"/><circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/>'
  }.freeze

  def ikon(nama, kelas: "w-5 h-5")
    jalur = JALUR.fetch(nama.to_s, JALUR["info"])
    "<svg xmlns=\"http://www.w3.org/2000/svg\" class=\"#{kelas}\" viewBox=\"0 0 24 24\" fill=\"none\" " \
      "stroke=\"currentColor\" stroke-width=\"1.8\" stroke-linecap=\"round\" stroke-linejoin=\"round\" " \
      "aria-hidden=\"true\">#{jalur}</svg>".html_safe
  end
end
