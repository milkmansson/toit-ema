// Copyright (C) 2025 Toit Contributors
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import ema show *

/**
Exmaple of using this Exponential Moving Average library:

Caluclate the alpha for 30 samples, with ALL older values not accounting for
more than 1% of the present average.  In addition, set the value ready for use
in the object:
*/

main:

  ema := Ema
  print (ema.compute-alpha-from-coverage 30 --coverage=0.99 --set)
