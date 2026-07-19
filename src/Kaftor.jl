module Kaftor
export rot4p

"""
    rot4p(n::UInt16,key::UInt8)

Rotates `n` in two parts of 9 and 7 bits, then exclusive-ors `n` with `key`,
then rotates `n` in two more parts of 5 and 11 bits, the number of bits rotated
depending on `key`.
"""
function rot4p(n::UInt16,key::UInt8)
  b5 =(key+1024)%5
  b7 =(key+1024)%7
  b9 =(key+1024)%9
  b11=(key+1024)%11
  p9=(((n&0x1ff)*0x00201)>>(9-b9))&0x1ff
  p7=(((((n&0xfe00)>>9)*0x00081)>>(7-b7))&0x7f)<<9
  n=(p7|p9)⊻key
  p5=(((n&0x1f)*0x00021)>>(5-b5))&0x1f
  p11=(((((n&0xffe0)>>5)*0x00801)>>(11-b11))&0x7ff)<<5
  UInt16(p11|p5)
end

end # module Kaftor
