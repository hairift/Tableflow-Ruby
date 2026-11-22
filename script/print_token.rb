Meja.order(:nomor_meja).each do |meja|
  puts "#{meja.nomor_meja} #{meja.token_qr}"
end
