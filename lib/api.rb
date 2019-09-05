# coding: utf-8
# this file provides a handy way to call win32api

class Dll
  def initialize dll
    @dll = dll.to_s
  end

  def method_missing func, *args
    imports = args.map { |e| Integer === e ? 'l' : 'p' }
    Win32API.new(@dll, func.to_s, imports, 'l').call(*args)
  end
end

def dll name
  Dll.new name
end

Kernel32 = dll 'kernel32'
User32   = dll 'user32'
Shell32  = dll 'shell32'
Ntdll    = dll 'ntdll'

class Buffer
  DIRECTIVES = {
    "C"  => 1, "c"  => 1, "A"  => 1, "a"  => 1, "Z"  => 1, "x"  => 1,
    "S"  => 2, "s"  => 2, "S_" => 2, "S!" => 2, "s_" => 2, "s!" => 2,
    "n"  => 2, "v"  => 2,
    "L"  => 4, "l"  => 4, "I"  => 4, "I_" => 4, "I!" => 4, "L_" => 4,
    "L!" => 4, "i"  => 4, "i_" => 4, "i!" => 4, "l_" => 4, "l!" => 4,
    "N"  => 4, "V"  => 4, "F"  => 4, "f"  => 4, "e"  => 4, "g"  => 4,
    "Q"  => 8, "q"  => 8, "D"  => 8, "d"  => 8, "E"  => 8, "G"  => 8,
  }

  def self.buf template=nil
    if template
      @buf = new template
    else
      @buf && @buf.unpack
    end
  end

  def initialize template
    @template = template
    @buffer = make_buffer template
  end

  attr_reader :buffer
  
  alias to_str buffer

  def make_buffer template=@template
    sum = template.scan(/([[:alpha:]][_!]?)(\d*)/).inject 0 do |sum, (d, n)|
      sum + DIRECTIVES[d] * (n.to_i.nonzero? || 1)
    end
    "\0" * sum
  end

  def unpack template=@template
    @buffer.unpack template
  end

  def size
    @buffer.bytesize
  end

  def inspect
    "#<Buffer:%#010x #{unpack.inspect}>" % (object_id << 1)
  end
end

def buf(*args)
  Buffer.buf(*args)
end
