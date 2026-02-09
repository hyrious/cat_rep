# coding: utf-8

$: << 'lib'
require 'helper'

rgss_main {
  Graphics.background_exec = true

  s = spr 'D:\SteamLibrary\steamapps\common\RPGVXAce\rtp\Graphics\Battlers\Succubus.png'
  s.ox = s.width / 2
  s.oy = s.height / 2
  s.x = Graphics.width / 2
  s.y = Graphics.height / 2

  ssr s, %{
    float offset = 0.01;
    float intensity = 0.5;
  }, %{
    float r_uv_x = clamp(texcoord.x - offset, 0.001, 0.999);
    float b_uv_x = clamp(texcoord.x + offset, 0.001, 0.999);
    float  red = tex2D(spriteSampler, float2(r_uv_x, texcoord.y)).r;
    float blue = tex2D(spriteSampler, float2(b_uv_x, texcoord.y)).b;
    float4 result = float4(red, res.g, blue, res.a);
    res = lerp(res, result, intensity);
  }

  loop {
    Graphics.update
    Input.update

    s.set_effect_param 'offset', Mouse.x * 1.0 / Graphics.width
    s.set_effect_param 'intensity', Mouse.y * 1.0 / Graphics.height
  }
}
