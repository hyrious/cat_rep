# coding: utf-8

$: << 'lib'
require 'stringex'
require 'api'

IME = dll 'rgss_ime.dll'

module CALLBACKS
  def self.on_mousewheel delta
    p delta
  end

  def self.on_langchange keyboard
    puts "IME language change #{keyboard}"
  end

  def self.on_composition_start
    # puts "IME composition start"
  end

  def self.on_composition cursor, length, wstr
    puts "IME composition #{cursor} #{length} #{wstr}"
    size = IME.candidateList Graphics.window_hwnd, nil
    return if size < 0
    buffer = "\x00" * size
    IME.candidateList Graphics.window_hwnd, buffer

    size, style, count, sel, pageStart, pageSize = buffer.unpack 'LLLLLL'
    offsets = buffer.slice(4 * 6, 4 * pageSize).unpack 'L*'
    candidates = offsets.map { |i| buffer.unpack("x#{i}Z*")[0].s2u.force_encoding('utf-8') }
    puts "IME candidates count=#{count} page=(#{pageStart}, #{pageSize})\n#{candidates.join("|")}"
  end

  def self.on_composition_result cursor, length, wstr
    puts "IME composition result #{cursor} #{length} #{wstr}"
  end
end

rgss_main {
  Graphics.background_exec = true
  IME.enable Graphics.window_hwnd
  rgss_stop
}
