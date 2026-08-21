module test
using Kaftor,Test,Printf,OffsetArrays
using Kaftor.Jumble,Kaftor.Mix3
export testRot4p,testJumble,testMix3,testMaxOrder,testVectors
export listSingleIpsi

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
  buf=UInt8[]
  for i in 0x00:0xf2
    for j in 0x00:0xf2
      for k in 0x00:0xf2
        push!(buf,((i+0x01)*(j+0x01))⊻k)
      end
    end
  end
  @test testMix3(buf)
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

function convolve(a::Integer,b::Integer)
  # a and b are 24-bit numbers
  ret=zero(a)
  a&=0xffffff
  b&=0xffffff
  for i in 0:23
    if isodd(count_ones(a&b))
      ret+=one(a)<<i
    end
    b=(b<<1&0xffffff)+((b&0x800000)>>23)
  end
  ret
end

function singleIpsi(a::Integer)
  convolve(a,a)==1
end

const mix3Table=OffsetVector(fill(0x000000,256),-1)

function fillMix3Table(pattern::Integer)
  pattern=(pattern&0xffffff)*0x001000001
  for i in 0:255
    mix3Table[i]=0
  end
  for i in 0:7
    for j in 1:255
      if j&(1<<i)>0
        mix3Table[j]⊻=(pattern>>i)&0xffffff
      end
    end
  end
end

function variety(vec::OffsetVector{<:Integer},n::Integer)
  tally=OffsetVector(fill(0x0000,256),-1)
  total=0
  for i in 0:n-1
    for j in 0:255
      tally[j]=0
    end
    for j in vec
      tally[j>>(8*i)&255]=1
    end
    total+=sum(tally)
  end
  total
end

function listSingleIpsi()
  mostVar=0
  for i in 0x0:0xffffff
    if count_ones(i)<=13 && count_ones(i)>=11 && singleIpsi(i)
      fillMix3Table(i)
      var=variety(mix3Table,3)
      if var>=mostVar
        mostVar=var
        @printf "%06x%4d\n" i var
      end
    end
  end
  println()
end

end
