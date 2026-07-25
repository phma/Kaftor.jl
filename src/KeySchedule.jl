module KeySchedule
using OffsetArrays
export keySchedule

function lfsr1(n::Integer)
  ((n&1)*0x84802140)⊻(n>>1)
end

const lfsr=OffsetArray(map(collect(0:255)) do x
  for i in 1:8
    x=lfsr1(x)
  end
  convert(UInt32,x)
end,0:255)

function fwdCrc!(vec::Vector{<:Integer})
  acc=0xdeadc0de
  @inbounds for i in eachindex(vec)
    acc=(acc>>8)⊻lfsr[acc&255]⊻vec[i]
    vec[i]=acc&255
  end
end

function thueFlip!(vec::Vector{UInt8},len::Integer)
  for i in eachindex(vec)
    if isodd(count_ones((i-1)÷len))
      vec[i]=~vec[i]
    end
  end
  vec
end

function keySchedule(vec::Vector{UInt8},len::Integer)
  ret=repeat(vec,cld(len,length(vec)))
  resize!(ret,len)
  fwdCrc!(ret)
  thueFlip!(ret,length(vec))
  ret
end

end
