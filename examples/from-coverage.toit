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
  ema := Ema --quiet

  // Print coverage table
  print (ema.compute-alpha-from-coverage 30 --coverage=0.85 --set)

  // Prints
  0.06127934198046303127
