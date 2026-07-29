module Kaftor
include("ShufflePairs.jl")
include("Mix3.jl")
include("Jumble.jl")
include("KeySchedule.jl")
using OffsetArrays,Primes,Mods
using .ShufflePairs,.Mix3,.Jumble,.KeySchedule
export rot4p,unrot4p,roundEncrypt!,kaftorEncrypt!

function roundEncrypt!(data::Vector{UInt8},round::Integer,key::Vector{UInt8},
		       wholePrime::Integer,wholeRPrime::Mod,
		       wholeInverse::Mod,tierceRPrime::Integer)
  jumble!(data,wholePrime,wholeInverse,wholeRPrime)
  shufflePairs!(data,round,key)
  mix3PartsSeq!(data,tierceRPrime)
end

function kaftorEncrypt!(data::Vector{UInt8},key::Vector{UInt8})
  scheduleLengths=OffsetVector(numsPairs(length(data)),-1)
  scheduledKey=keySchedule(key,sum(scheduleLengths))
  start=1
  wholePrime=nextprime(length(data)+3)
  wholeRPrime=Mod{wholePrime}(findMaxOrder(wholePrime))
  wholeInverse=inv(wholeRPrime)
  tierceRPrime=findMaxOrder(length(data)÷3)
  for round in eachindex(scheduleLengths)
    roundEncrypt!(data,round,scheduledKey[start:start+scheduleLengths[round]-1],
		 wholePrime,wholeRPrime,wholeInverse,tierceRPrime)
    start+=scheduleLengths[round]
  end
end

end # module Kaftor
