# coding: utf-8

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
  [rand(32768), 'Main', Zlib::Deflate.deflate(<<-RUBY)]
    $: << 'lib'
    require 'background_running'
    require 'full_error'
    require 'conhost'
    Font.default_name = ['等距更纱黑体 T SC']
    rgss_main { rgss_stop }
  RUBY
], 'Scripts.rvdata2'

open 'Game.ini', 'w' do |f|
  f.puts <<-INI.strip_heredoc
    [Game]
    RTP=RPGVXAce
    Library=RGSS301.dll
    Scripts=Scripts.rvdata2
    Title=Project1
  INI
end

def Dir.tmpdir
  @_tmpdir ||= ENV['TEMP'].tr '\\', '/'
end

class CatRep
  def self.method_missing suffix
    File.join Dir.tmpdir, "cat_rep.#{suffix}"
  end
end

def output file, text
  open file, 'w' do |f|
    f.write text
  end
end

stdout_thread = Thread.new do
  loop do
    sleep 0.02 until File.exist? CatRep.stdout
    puts File.read CatRep.stdout
    File.delete CatRep.stdout
  end
end

stderr_thread = Thread.new do
  loop do
    sleep 0.02 until File.exist? CatRep.stderr
    puts "\e[1m\e[31m#{File.read(CatRep.stderr)}\e[0m"
    File.delete CatRep.stderr
  end
end

def remote_eval text
  File.delete CatRep.o
  output CatRep.i, text
  sleep 0.02 until File.exist? CatRep.o
  File.read CatRep.o
end

require 'api'
require 'wirb-colorize'
require 'stringex'

hwnd = Kernel32.GetConsoleWindow
pid = spawn 'Game.exe', 'test'
sleep 0.2
User32.SetForegroundWindow hwnd

BUFSIZ = 512
STD_INPUT_HANDLE = -10
@h_stdin = Kernel32.GetStdHandle(STD_INPUT_HANDLE)
@buffer  = "\0" * BUFSIZ
@read    = buf('l')

loop do
  print '>> '
  Kernel32.ReadConsole(@h_stdin, @buffer, BUFSIZ, @read, 0)
  text = @buffer.unpack('A*')[0].chomp.s2u
  break if text == 'exit'
  puts "=> #{Wirb.colorize_result remote_eval text}"
  Ntdll.memset(@buffer, 0, BUFSIZ)
end

def unsafe
  yield
rescue
end

unsafe { Process.kill 9, pid }
unsafe { File.delete 'Scripts.rvdata2', 'Game.ini' }
unsafe { File.delete CatRep.i, CatRep.o, CatRep.stdout, CatRep.stderr }
