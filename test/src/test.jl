module test
using Kaftor,Test
using Kaftor.Jumble,Kaftor.Mix3
export testRot4p,testJumble,testMix3,testMaxOrder,testVectors

key96_0 = "Водворетраванатраведрова.Нерубидрованатраведвора!"
key96_1 = "Водворетраванатраведрова.Нерубидрованатраведвора "
key96_2 = "Водворетраванатраведрова,Нерубидрованатраведвора!"
key96_3 = "Водворетраванатраведрова,Нерубидрованатраведвора "
# Russian tongue twister
# In the yard is grass, on the grass is wood.
# Do not chop the wood on the grass of yard.
# 96 bytes in UTF-8 with single bit changes.

key30_0 = "Παντοτε χαιρετε!"
key30_1 = "Πάντοτε χαιρετε!"
key30_2 = "Παντοτε χαίρετε!"
key30_3 = "Πάντοτε χαίρετε!"
# Always rejoice! 1 Thess. 5:16.

key6_0 = "aerate"
key6_1 = "berate"
key6_2 = "cerate"
key6_3 = "derate"

# Text size Key extended to
#	  6	  7
#	  8	 12
#	 15	 28
#	 16	 32
#	 30	 71
#	 39	 96
#	 96	304

function mix3PartsSeq!(buf::Vector{<:Integer},rprime::Integer)
  len=div(length(buf),3)
  a=1
  b=2*len
  c=2*len+1
  Kaftor.Mix3.mix3Worker!(buf,a,b,c,1,rprime,len)
end

function testMaxOrder()
  @test Kaftor.findMaxOrder(85)==54
  @test Kaftor.findMaxOrder(1618034)==1000001
  @test Kaftor.findMaxOrder(1)==1
end

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
  mix3PartsPar!(buf,rprime)
  mix3PartsSeq!(buf,rprime)
  orig==buf
end

function testJumble()
  @test testJumble(collect(0x00:0xa2))
end

function testMix3()
  @test testMix3(collect(0x00:0xa2))
end

function testVector(key,plaintext,ciphertext::Vector{UInt8})
  plaintext=Vector{UInt8}(plaintext)
  text=copy(plaintext)
  kaftorEncrypt!(text,key)
  ret=text==ciphertext
  if !ret
    println("Expected ciphertext: ",ciphertext,"\nGot: ",text)
  end
  kaftorDecrypt!(text,key)
  ret&=text==plaintext
  ret
end

function testVectors()
  @test testVector(key6_0,[0,0,0,0,0,0,0,0],
		   [ 0x56, 0x5c, 0x2a, 0xb7, 0x1a, 0xe3, 0x85, 0x4e
		   ])
end

end
