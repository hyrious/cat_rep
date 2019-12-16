# coding: utf-8

def spr(a, o={})
  b = case a
  when Array  then Bitmap.new(*a)
  when String then Bitmap.new( a)
  when Bitmap then             a
  end
  s = Sprite.new
  s.bitmap = b
  o.each { |k, v| s.public_send("#{k}=", v) }
  yield s, b if block_given?
  s
end

PFUNC_TEMPLATE = <<-CPP
{{g}}

PS_OUTPUT {{n}}(float4 color: COLOR0, float2 texcoord: TEXCOORD0) {
  float4 res = tex2D(spriteSampler, texcoord);
  // res = ColorMap(res);
  // res = BushMap(res, texcoord);
  res *= color;
  // res = ToneMap(res);
  {{f}}
  res.rgb *= res.a;
  return GetOutput(res);
}
CPP

PPASS_TEMPLATE = <<-CPP
pass {{n}}_PASS {
  AlphaBlendEnable = true;
  SeparateAlphaBlendEnable = true;

  BlendOp = ADD;
  SrcBlend = ONE;
  DestBlend = INVSRCALPHA;
  SrcBlendAlpha = ONE;
  DestBlendAlpha = INVSRCALPHA;

  PixelShader = compile ps_2_0 {{n}}();
}
CPP

def ssr(s, g, f=nil)
  n = [*'a'..'z'].sample(rand(8) + 1).join.capitalize
  f, g = g, '' if f.nil?
  pfunc = PFUNC_TEMPLATE.gsub('{{g}}', g).gsub('{{n}}', n).gsub('{{f}}', f)
  puts pfunc
  ppass = PPASS_TEMPLATE.gsub('{{n}}', n)
  Graphics.add_shader pfunc, ppass
  s.effect_name = "#{n}_PASS"
end
