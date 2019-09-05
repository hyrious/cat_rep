class String

  @@MultiByteToWideChar  = Win32API.new('kernel32', 'MultiByteToWideChar', 'ilpipi', 'i')
  @@WideCharToMultiByte  = Win32API.new('kernel32', 'WideCharToMultiByte', 'ilpipipp', 'i')

  def u2w
    i = @@MultiByteToWideChar.call(65001, 0 , self, -1, nil,0)
    buffer = "\0" * (i*2)
    @@MultiByteToWideChar.call(65001, 0 , self, -1, buffer, i)
    buffer.chop!
    return buffer
  end  

  def u2s
    i = @@MultiByteToWideChar.call(65001, 0 , self, -1, nil,0)
    buffer = "\0" * (i*2)
    @@MultiByteToWideChar.call(65001, 0 , self, -1, buffer, i)
    i = @@WideCharToMultiByte.call(0, 0, buffer, -1, nil, 0, nil, nil)
    result = "\0" * i
    @@WideCharToMultiByte.call(0, 0, buffer, -1, result, i, nil, nil)
    result.chop!
    return result
  end

  def s2u
    i = @@MultiByteToWideChar.call(0, 0, self, -1, nil, 0)
    buffer = "\0" * (i*2)
    @@MultiByteToWideChar.call(0, 0, self, -1, buffer, buffer.size / 2)
    i = @@WideCharToMultiByte.call(65001, 0, buffer, -1, nil, 0, nil, nil)
    result = "\0" * i
    @@WideCharToMultiByte.call(65001, 0, buffer, -1, result, result.size, nil, nil)
    result.chop!
    return result
  end
end