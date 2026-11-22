# Periksa sintaks semua template ERB tanpa merender aplikasi.
require "action_view"

Dir.glob("app/views/**/*.erb").sort.each do |path|
  sumber = File.read(path)
  begin
    kode = ActionView::Template::Handlers::ERB.erb_implementation.new(sumber, trim: true).src
    # Layout memakai yield, jadi kode harus dikompilasi di dalam method.
    RubyVM::InstructionSequence.compile("def __cek_template__\n#{kode}\nend")
  rescue SyntaxError => e
    puts "GAGAL #{path}: #{e.message.lines.first(2).join.strip}"
  rescue StandardError => e
    puts "ERROR #{path}: #{e.class} #{e.message}"
  end
end

puts "Selesai cek ERB"
