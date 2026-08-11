module bench
using Kaftor,BenchmarkTools,ProfileView
using Kaftor.Jumble,Kaftor.Mix3
export kaftorTime,kaftorProf,jumbleTime,mix3Time

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

function jumbleTime(textLen::Integer)
  text=fill(0x69,textLen)
  trial=@benchmark jumble!($text)
  median(trial).time
end

function mix3Time(textLen::Integer)
  text=fill(0x69,textLen)
  rprime=findMaxOrder(textLen÷3)
  trial=@benchmark mix3PartsPar!($text,$rprime)
  median(trial).time
end

end
