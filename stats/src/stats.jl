module stats
using Kaftor
export big3Power,big5Power

function big3Power(n::Integer)
  big(3)^(n*53÷84)
end

function big5Power(n::Integer)
  big(5)^(n*146÷339)
end

end
