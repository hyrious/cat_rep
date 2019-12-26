# coding: utf-8
require_relative 'lib/ctrl_b'
require_relative 'lib/helper'

bg = spr [Graphics.width, Graphics.height]
ssr bg, %{
  res = 0.5f;
}

def sample_sprite char, opt={}
  spr [100, 100], opt do |s, b|
    b.font.size = 72
    b.font.color = Color.new(0x66, 0xcc, 0xff)
    b.font.outline = false
    b.draw_text b.rect, char, 1
    s.ox, s.oy = s.width / 2, s.height / 2
    s.x, s.y = Graphics.width / 2, Graphics.height / 2
  end
end

v = Viewport.new
s = sample_sprite '⑨', viewport: v
s.x -= 18
t = sample_sprite '葱', viewport: v
t.x += 18

# float4 res, color;
# float2 texcoord;
ssr v, %{
  static const float PIXEL_SIZE = 4.0;
}, %q[
  float2 one = float2(sampWidth, sampHeight);
  float2 sqa = one * PIXEL_SIZE;
  texcoord = sqa * floor(texcoord / sqa);
  for (int i = 0; i < int(PIXEL_SIZE); ++i)
    for (int j = 0; j < int(PIXEL_SIZE); ++j)
      res += tex2D(spriteSampler, texcoord + one * float2(i, j));
  res /= pow(PIXEL_SIZE, 2.0);
]

Graphics.background_exec = true
rgss_main {
  loop {
    Mouse.update
    Graphics.update
  }
}
