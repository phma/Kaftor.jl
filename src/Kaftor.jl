module Kaftor
include("Rotate4Parts.jl")
include("Mix3.jl")
include("Jumble.jl")
using OffsetArrays
using .Rotate4Parts,.Mix3
export rot4p,unrot4p

end # module Kaftor
