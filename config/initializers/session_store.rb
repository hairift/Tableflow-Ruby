# Sesi berbasis cookie dengan atribut keamanan yang ketat.
Rails.application.config.session_store :cookie_store,
  key: "_tableflow_scan_sesi",
  httponly: true,
  secure: Rails.env.production?,
  same_site: :lax,
  expire_after: 30.minutes
