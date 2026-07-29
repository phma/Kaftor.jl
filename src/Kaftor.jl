module Kaftor
include("ShufflePairs.jl")
include("Mix3.jl")
include("Jumble.jl")
include("KeySchedule.jl")
using OffsetArrays,Mods
using .ShufflePairs,.Mix3,.Jumble,.KeySchedule
export rot4p,unrot4p,roundEncrypt!

function roundEncrypt!(data::Vector{UInt8},round::Integer,key::Vector{UInt8},
		       wholePrime::Integer,wholeRPrime::Mod,
		       wholeInverse::Mod,tierceRPrime::Integer)
  jumble!(data,wholePrime,wholeInverse,wholeRPrime)
  shufflePairs!(data,round,key)
  mix3PartsSeq!(data,tierceRPrime)
end

end # module Kaftor
