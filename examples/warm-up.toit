// Copyright (C) 2025 Toit Contributors
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import ema show *

/**
Simple example of the use of an ema, showing convergence:
*/

main:
  test-alpha/float := 0.25

  // Construct the ema object, giving an alpha value at instantiation
  ema := Ema test-alpha

  // Print coverage table
  ema.compute-ema-weights-from-alpha test-alpha --n=20

  // Set required coverage for `is-warmed` to 97%
  ema.set-required-coverage 0.97

  // add a set of values, with the occasional test for '95% coverage'
  ema.add 53.33 --log
  ema.add 72.50 --log
  ema.add 91.67 --log
  ema.add 115.00 --log
  ema.add 1224.17 --log
  print "     Average: $(ema.average) Samples: $(ema.samples) Coverage: $(%0.3f ema.coverage) is-warmed:$(ema.is-warmed)"

  ema.add 1914.17 --log
  ema.add 2601.67 --log
  ema.add 3862.50 --log
  ema.add 5882.50 --log
  ema.add 6173.33 --log
  print "     Average: $(ema.average) Samples: $(ema.samples) Coverage: $(%0.3f ema.coverage) is-warmed:$(ema.is-warmed)"

  ema.add 6827.50 --log
  ema.add 7308.33 --log
  ema.add 7046.67 --log
  ema.add 5127.50 --log
  ema.add 2533.33 --log
  print "     Average: $(ema.average) Samples: $(ema.samples) Coverage: $(%0.3f ema.coverage) is-warmed:$(ema.is-warmed)"

  ema.add 880.00 --log
  ema.add 4587.50 --log
  ema.add 4507.50 --log
  ema.add 3100.00 --log
  ema.add 2480.83 --log
  print "     Average: $(ema.average) Samples: $(ema.samples) Coverage: $(%0.3f ema.coverage) is-warmed:$(ema.is-warmed)"

  ema.add 1453.33 --log
  ema.add 107.50 --log
  ema.add 330.00 --log
  ema.add 2149.17 --log
  ema.add 149.17 --log
  print "     Average: $(ema.average) Samples: $(ema.samples) Coverage: $(%0.3f ema.coverage) is-warmed:$(ema.is-warmed)"


  ema.add 5.00 --log
  ema.add 658.33 --log
  ema.add 3850.00 --log
  ema.add 3653.33 --log
  ema.add 1800.83 --log
  print "     Average: $(ema.average) Samples: $(ema.samples) Coverage: $(%0.3f ema.coverage) is-warmed:$(ema.is-warmed)"

  ema.add 317.50 --log
  ema.add 35.83 --log
  ema.add 10.00 --log
  ema.add 9.17 --log
  ema.add 9.17 --log
  print "     Average: $(ema.average) Samples: $(ema.samples) Coverage: $(%0.3f ema.coverage) is-warmed:$(ema.is-warmed)"

  ema.add 9.17 --log
  ema.add 9.17 --log
  ema.add 9.17 --log
  ema.add 9.17 --log
  ema.add 9.17 --log
  print "     Average: $(ema.average) Samples: $(ema.samples) Coverage: $(%0.3f ema.coverage) is-warmed:$(ema.is-warmed)"

  ema.add 9.17 --log
  ema.add 9.17 --log
  ema.add 9.17 --log
  ema.add 9.17 --log
  ema.add 9.17 --log
  print "     Average: $(ema.average) Samples: $(ema.samples) Coverage: $(%0.3f ema.coverage) is-warmed:$(ema.is-warmed)"

  ema.add 9.17 --log
  ema.add 9.17 --log
  ema.add 9.17 --log
  ema.add 9.17 --log
  ema.add 9.17 --log
  print "     Average: $(ema.average) Samples: $(ema.samples) Coverage: $(%0.3f ema.coverage) is-warmed:$(ema.is-warmed)"

  ema.add 9.17 --log
  ema.add 9.17 --log
  ema.add 9.17 --log
  ema.add 9.17 --log
  ema.add 9.17 --log
  print "     Average: $(ema.average) Samples: $(ema.samples) Coverage: $(%0.3f ema.coverage) is-warmed:$(ema.is-warmed)"
