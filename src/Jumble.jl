module Jumble
# Modified from code I wrote for Real Random
include("Mix3.jl")
using Base.Threads,Primes,Mods
using .Mix3
export jumble!

perThread::Int=2^16

function jumbleWorker!(data::Vector{<:Integer},p,q,r,n,t,imod,jmod,thue)
  len=length(data)
  while n<=(p-3)÷2
    i=value(imod)-1
    j=value(jmod)-1
    if i<=len && j<=len
      (data[i],data[j])=(data[i]⊻data[j]&thue,data[j]⊻data[i]&~thue)
    end
    imod*=r
    jmod*=q
    n+=t
    if n%yieldInterval==0
      yield()
    end
  end
end

function jumble!(data::Vector{<:Integer},p::Integer,q::Mod,r::Mod)
  thue=0x9669699669969669&(typemax(eltype(data))⊻typemin(eltype(data)))
  t=max(1,min(length(data)÷perThread,nthreads()))
  if t==1
    jumbleWorker!(data,p,q,r,1,t,r,q,thue)
  else
    tasks=Task[]
    for n in 1:t
      push!(tasks,@spawn jumbleWorker!(data,p,q^t,r^t,$n,t,$r^n,$q^n,thue))
    end
    for i in 1:t
      wait(tasks[i])
    end
  end
  return nothing
end

"""
  jumble!(data::Vector{<:Integer})

Make bytes in `data` affect each other if their positions are multiplicative
inverses mod the next prime. The function is an involution.
"""
function jumble!(data::Vector{<:Integer})
  len=length(data)
  p=nextprime(len+3) # skip -1, 0, and 1
  r=Mod{p}(findMaxOrder(p))
  q=inv(Mod{p}(r))
  jumble!(data,p,q,r)
end

end
