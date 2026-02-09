# coding: utf-8

$: << 'lib'
require 'helper'

rgss_main {
  Graphics.background_exec = true

  b = Bitmap.new 'D:\SteamLibrary\steamapps\common\RPGVXAce\rtp\Graphics\Battlers\Succubus.png'
  b.process_color { |arr|
    offset = 5
    length = arr.size - offset.abs
    length.times { |i|
      arr[i].red = arr[i + offset].red
    }
  }
  s = spr b

  loop {
    Graphics.update
    Input.update
  }
}
