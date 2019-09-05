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
