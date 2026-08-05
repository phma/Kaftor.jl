module bench
using Kaftor,BenchmarkTools,ProfileView
export kaftorTime,kaftorProf

function kaftorTime(textLen::Integer,keyLen::Integer) # in nanoseconds
  text=fill(0x69,textLen)
  key=fill(0x96,keyLen)
  trial=@benchmark kaftorEncrypt!($text,$key)
  median(trial).time
end

function kaftorProf(textLen::Integer,keyLen::Integer)
  text=fill(0x69,textLen)
  key=fill(0x96,keyLen)
  @profview kaftorEncrypt!(text,key)
end

end
