module bench
using Kaftor,BenchmarkTools
export kaftorTime

function kaftorTime(textLen::Integer,keyLen::Integer) # in nanoseconds
  text=fill(0x69,textLen)
  key=fill(0x96,keyLen)
  trial=@benchmark kaftorEncrypt!($text,$key)
  median(trial).time
end

end
