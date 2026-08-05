module ShufflePairs
using OffsetArrays,Base.Threads
export rot4p,unrot4p,numsPairs,shufflePairs!,unshufflePairs!

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
  n=(p7|p9)⊻(key|0x6900)
  p5=(((n&0x1f)*0x00021)>>(5-b5))&0x1f
  p11=(((((n&0xffe0)>>5)*0x00801)>>(11-b11))&0x7ff)<<5
  UInt16(p11|p5)
end

"""
    unrot4p(n::UInt16,key::UInt8)

Rotates `n` in two parts of 5 and 11 bits, then exclusive-ors `n` with `key`,
then rotates `n` in two more parts of 9 and 7 bits, the number of bits rotated
depending on `key`. Undoes `rot4p`.
"""
function unrot4p(n::UInt16,key::UInt8)
  b5 =(key+1024)%5
  b7 =(key+1024)%7
  b9 =(key+1024)%9
  b11=(key+1024)%11
  p5=(((n&0x1f)*0x00021)>>b5)&0x1f
  p11=(((((n&0xffe0)>>5)*0x00801)>>b11)&0x7ff)<<5
  n=(p11|p5)⊻(key|0x6900)
  p9=(((n&0x1ff)*0x00201)>>b9)&0x1ff
  p7=(((((n&0xfe00)>>9)*0x00081)>>b7)&0x7f)<<9
  UInt16(p7|p9)
end

const revInxBitTable16=OffsetVector(UInt16[],-1)

function fillRevInx16()
  ri=OffsetVector([0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15],-1)
  for n in 0:65535
    m=0
    for i in 0:15
      if n&(1<<i)>0
	m+=1<<ri[i]
      end
    end
    push!(revInxBitTable16,m)
  end
end

fillRevInx16()

function revInxBit(n::UInt16)
  if length(revInxBitTable16)!=65536
    empty!(revInxBitTable16)
    fillRevInx16()
  end
  revInxBitTable16[n]
end

"""
    rot4p(a::UInt8,b::UInt8,key::UInt8)

Interleaves `a` and `b` giving `n`, rotates `n` in four parts exclusive-oring
with `key` in the middle, uninterleaves the result, and returns two bytes.
"""
function rot4p(a::UInt8,b::UInt8,key::UInt8)
  n=revInxBit(a*0x100+b)
  m=revInxBit(rot4p(n,key))
  UInt8((m>>8)&0xff),UInt8(m&0xff)
end

"""
    unrot4p(a::UInt8,b::UInt8,key::UInt8)

Undoes `rot4p(a,b,key)`.
"""
function unrot4p(a::UInt8,b::UInt8,key::UInt8)
  n=revInxBit(a*0x100+b)
  m=revInxBit(unrot4p(n,key))
  UInt8((m>>8)&0xff),UInt8(m&0xff)
end

"""
    numPairs(n::Integer,round::Integer)

Compute how many pairs of numbers in 0:`n`-1 differ by 2^`round`. This is
how many bytes of key schedule are used in round `round`.
"""
function numPairs(n::Integer,round::Integer)
  pow=1<<round
  ret=(n÷2)&(-pow)
  if n&pow!=0
    ret+=n&(pow-1)
  end
  ret
end

"""
    numsPairs(n::Integer)

List the number of bytes of key schedule that are used in each round.
The sum of the returned `Vector` is A000788.
"""
function numsPairs(n::Integer)
  ret=typeof(n)[]
  i=0
  while true
    np=numPairs(n,i)
    if np==0
      break
    end
    push!(ret,np)
    i+=1
  end
  ret
end

function shufflePairs!(buf::Vector{UInt8},round::Integer,key::Vector{UInt8})
  # buf would be easier if it started at 0, but jumble! would be easier if it
  # started at 2, so it's starting at 1 as is usual in Julia.
  h=1<<round
  @threads for i in eachindex(key)
    j=i+((i-1)&-h)
    buf[j],buf[j+h]=rot4p(buf[j],buf[j+h],key[i])
  end
end

function unshufflePairs!(buf::Vector{UInt8},round::Integer,key::Vector{UInt8})
  h=1<<round
  @threads for i in eachindex(key)
    j=i+((i-1)&-h)
    buf[j],buf[j+h]=unrot4p(buf[j],buf[j+h],key[i])
  end
end

end
