module stats
using Kaftor
export big3Power,big5Power,messageArray,messageBignum,tickle

function big3Power(n::Integer)
  big(3)^(n*53÷84)
end

function big5Power(n::Integer)
  big(5)^(n*146÷339)
end

function messageArray(pt::Integer,clutchMsgLen::Integer) # also used for keys
  ret=Vector{UInt8}(undef,clutchMsgLen)
  for i in 1:clutchMsgLen
    ret[i]=UInt8(pt&0xff)
    pt>>=8
  end
  ret
end

function messageBignum(text::Vector{UInt8})
  ret=big(0)
  for i in reverse(eachindex(text))
    ret=ret*256+text[i]
  end
  ret
end

function tickle(n::Integer,key::Vector{UInt8})
  ret=BigInt[]
  buf0=messageArray(0,n)
  kaftorEncrypt!(buf0,key)
  ct0=messageBignum(buf0)
  for i in 0:n*8-1
    buf1=messageArray(big(1)<<i,n)
    kaftorEncrypt!(buf1,key)
    ct1=messageBignum(buf1)
    push!(ret,ct1⊻ct0)
  end
  ret
end

end
