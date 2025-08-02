# coding: utf-8

RGD = !!(ARGV.delete '--rgd')
NORTP = !!(ARGV.delete '--nortp')

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
    $: << 'lib'
    require 'background_running'
    require 'full_error'
    require 'conhost'
    require 'helper'
    require 'api'
    Font.default_name = ['等距更纱黑体 SC', '微软雅黑', '黑体', 'Segoe UI']
    rgss_main { rgss_stop }
  RUBY
], 'Scripts.rvdata2'

open (RGD ? 'RGD.ini' : 'Game.ini'), 'w' do |f|
  f.puts <<-INI.strip_heredoc
    [Game]
    RTP=#{(RGD || NORTP) ? '' : 'RPGVXAce'}
    Title=Project1
    Library=RGSS301.dll
    Scripts=Scripts.rvdata2
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
    puts "\e[1m\e[31m#{File.read CatRep.stderr}\e[0m"
    File.delete CatRep.stderr
  end
end

def complete? text
  catch(:out) { eval "BEGIN { throw :out }; #{text}" }
  text
rescue SyntaxError
  nil
end

def push_history text
  open 'history.txt', 'a' do |f|
    f.puts text
  end
  text
end

def remote_eval text
  push_history ">> #{text}"
  File.delete CatRep.o if File.exist? CatRep.o
  output CatRep.i, text
  sleep 0.02 until File.exist? CatRep.o
  (File.read CatRep.o).tap { |s| push_history "=> #{s}" }
end

require 'api'
require 'wirb-colorize'
require 'stringex'

hwnd = Kernel32.GetConsoleWindow
pid = spawn (RGD ? 'RGD.exe' : 'Game.exe'), 'test'
sleep 0.2
User32.SetForegroundWindow hwnd

BUFSIZ = 512
STD_INPUT_HANDLE = -10
@h_stdin = Kernel32.GetStdHandle(STD_INPUT_HANDLE)
@buffer  = "\0" * BUFSIZ
@read    = buf('l')
@text    = []
@prompt  = '>> '

puts 'Type "exit" to quit.'
loop do
  print @prompt
  Kernel32.ReadConsole(@h_stdin, @buffer, BUFSIZ, @read, 0)
  text = @buffer.unpack('A*')[0].chomp
  if text == "\x11" # ^Q
    @text = []
  elsif text == "\x17" # ^W
    puts "=> #{Wirb.colorize_result remote_eval @text.join("\n")}"
    @text = []
    @prompt  = '>> '
  else
    text = text.s2u
    @text << text
    break if @text == ['exit']
    if text = complete?(@text.join("\n").force_encoding('utf-8'))
      puts "=> #{Wirb.colorize_result remote_eval text}"
      @text = []
      @prompt  = '>> '
    else
      if @text.size == 1
        puts '# Input ctrl+q<enter> to discard the buffer, ctrl+w<enter> to submit anyway.'
      end
      @prompt = '.. '
    end
  end
  Ntdll.memset(@buffer, 0, BUFSIZ)
end

def unsafe
  yield
rescue
end

unsafe { Process.kill 9, pid }
unsafe { File.delete 'Scripts.rvdata2', (RGD ? 'RGD.ini' : 'Game.ini') }
unsafe { File.delete CatRep.i, CatRep.o, CatRep.stdout, CatRep.stderr }
