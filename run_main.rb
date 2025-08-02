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

begin
  system 'Game.exe', 'test', 'console'
  File.delete 'Scripts.rvdata2', 'Game.ini'
rescue
end
