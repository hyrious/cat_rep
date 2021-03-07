class Object
  def try sym, *args
    __send__ sym, *args if respond_to? sym
  end
end

class String
  def strip_heredoc
    indent = scan(/^[ \t]*(?=\S)/).min.try(:size) || 0
    gsub(/^[ \t]{#{indent}}/, '')
  end
end

save_data [
  [rand(32768), 'Main', Zlib::Deflate.deflate(<<-RUBY.strip_heredoc)]
    require 'main.rb'
  RUBY
], 'Scripts.rvdata2'

open 'Game.ini', 'w' do |f|
  f.puts <<-INI.strip_heredoc
    [Game]
    RTP=
    Title=Project1
    Library=RGSS301.dll
    Scripts=Scripts.rvdata2
  INI
end

require 'api'
hwnd = Kernel32.GetConsoleWindow
User32.ShowWindow hwnd, 6
# User32.ShowWindow hwnd, 0

system 'Game.exe', 'test', 'console'

begin
  File.delete 'Scripts.rvdata2', 'Game.ini'
rescue
end
