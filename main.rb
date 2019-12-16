# coding: utf-8
require_relative 'lib/ctrl_b'
require_relative 'lib/helper'

bg = spr [Graphics.width, Graphics.height]
ssr bg, %{
  res = 0.5f;
}

s = spr [100, 100] do |_, b|
  b.font.size = 72
  b.font.color = Color.new(0x66, 0xcc, 0xff)
  b.font.outline = false
  b.draw_text b.rect, '⑨', 1
end
s.ox, s.oy = s.width / 2, s.height / 2
s.x, s.y = Graphics.width / 2, Graphics.height / 2

# float4 res, color;
# float2 texcoord;
ssr s, %{
  static const float DOUBLE_PI = PI * 2;
  static const float ANGLE_STEP = PI * 0.2;
  
  float thickness = 1;
}, %q[
  float4 cur;
  float maxA = 0.0;
  float2 displaced;
  for (float angle = 0.0; angle < DOUBLE_PI; angle += ANGLE_STEP) {
    displaced = texcoord + thickness * float2(sampWidth * cos(angle), sampHeight * sin(angle));
    cur = tex2D(spriteSampler, displaced);
    maxA = max(maxA, cur.a);
  }
  maxA = max(maxA, res.a);
  res = float4(res.rgb + (1.0 - res.a) * maxA, maxA);
]

Graphics.background_exec = true
rgss_main {
  loop {
    Mouse.update
    s.set_effect_param 'thickness', Mouse.x * 4.0 / Graphics.width
    Graphics.update
  }
}
