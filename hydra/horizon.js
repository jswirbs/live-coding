
osc(20, 0.03, 1.7)
  .kaleid()
  .mult(osc(20, 0.001, 0)
  .rotate(1.57)).blend(o0, 0.7)
  .modulateScale(osc(10, 0),-0.05)
  .scale(0.8, () => (1.05 + 0.1 * Math.sin(0.15*time)))
  .out(o0)
