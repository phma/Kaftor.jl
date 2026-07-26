module Kaftor
include("ShufflePairs.jl")
include("Mix3.jl")
include("Jumble.jl")
include("KeySchedule.jl")
using OffsetArrays
using .ShufflePairs,.Mix3,.Jumble,.KeySchedule
export rot4p,unrot4p

end # module Kaftor
