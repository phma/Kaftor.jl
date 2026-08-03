module test
using Kaftor,Test
using Kaftor.Jumble,Kaftor.Mix3
export testRot4p,testJumble,testMix3

function testRot4p(n::Int)
  a=UInt8(n>>16&255)
  b=UInt8(n>>8&255)
  key=UInt8(n&255)
  c,d=rot4p(a,b,key)
  e,f=unrot4p(c,d,key)
  a==e && b==f
end

function testRot4p()
  for i in 0:465:1048575
    @test testRot4p(i)
  end
end

function testJumble(buf::Vector{UInt8})
  orig=copy(buf)
  jumble!(buf)
  jumble!(buf)
  orig==buf
end

function testMix3(buf::Vector{UInt8})
  orig=copy(buf)
  rprime=findMaxOrder(length(buf)÷3)
  mix3PartsSeq!(buf,rprime)
  mix3PartsSeq!(buf,rprime)
  orig==buf
end

function testJumble()
  @test testJumble(collect(0x00:0xa2))
end

function testMix3()
  @test testMix3(collect(0x00:0xa2))
end

end
