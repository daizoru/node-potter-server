self.addEventListener "message", ((e) ->
  cycles = e.data
  postMessage "Calculating Pi using " + cycles + " cycles"
  numbers = calculatePi(cycles)
  postMessage "Result: " + numbers
), false

calculatePi = (cycles) ->
  pi = 0
  n  = 1
  for i in [0...cycles]
    pi = pi + (4/n) - (4 / (n+2))
    n  = n  + 4
  pi