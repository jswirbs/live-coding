
osc(20,0.1,1.3)
  .modulateScale(osc(40,0,1).kaleid(8))
  .repeat(2,4)
  .modulate(o0,0.03)
  .modulateKaleid(shape(1,0.1,1))
  .contrast( amount = 0.5 )
  .out(o0)
