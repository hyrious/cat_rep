# coding: utf-8
require_relative 'lib/ctrl_b'
require_relative 'lib/helper'

def make c
  s = spr([32, 32]) { |_, b| b.draw_text b.rect, c, 1 }
  s.ox, s.oy = s.width / 2, s.height / 2
  s
end

def update s, t
  s.x = 2 * t * Math.sin(2.0 * Graphics.frame_count / t)
  s.y = -2 * t * Math.cos(2.0 * Graphics.frame_count / t)
  s.angle += t
end

sun = make '★'
earth = make '○'
luna = make '·'

sun.add_child earth
earth.add_child luna

Graphics.vsync = false
Graphics.frame_rate = 250
Graphics.background_exec = true
rgss_main {
  loop {
    Mouse.update
    sun.x, sun.y = Mouse.x, Mouse.y
    sun.angle -= 1
    update earth, 40
    update luna, 10
    Graphics.update
  }
}
