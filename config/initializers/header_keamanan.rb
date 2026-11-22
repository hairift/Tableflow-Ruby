# Header respons yang memperkuat keamanan browser.
Rails.application.config.content_security_policy do |kebijakan|
  kebijakan.default_src :self
  kebijakan.font_src :self, "https://fonts.gstatic.com"
  kebijakan.img_src :self, "data:"
  kebijakan.object_src :none
  kebijakan.script_src :self, :unsafe_inline
  kebijakan.style_src :self, :unsafe_inline, "https://fonts.googleapis.com"
  kebijakan.connect_src :self
  kebijakan.base_uri :self
  kebijakan.frame_ancestors :none
end

Rails.application.config.content_security_policy_nonce_generator = ->(_permintaan) { SecureRandom.base64(16) }
Rails.application.config.content_security_policy_nonce_directives = %w[script-src]

# Menyembunyikan informasi server dan mengizinkan frame hanya pada situs sendiri.
Rails.application.config.action_dispatch.default_headers = {
  "X-Frame-Options" => "SAMEORIGIN",
  "X-Content-Type-Options" => "nosniff",
  "X-XSS-Protection" => "1; mode=block",
  "Referrer-Policy" => "strict-origin-when-cross-origin",
  "Permissions-Policy" => "camera=(), microphone=(), geolocation=()"
}
