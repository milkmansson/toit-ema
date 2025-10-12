// Copyright (C) 2025 Toit Contributors
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import ema show *


main:
  // Instantiate the object:
  ema := Ema

  // Set the Alpha:
  ema.set-alpha 0.37

  // Add values:
  ema.add 1
  ema.add 2
  ema.add 3
  ema.add 3

  // Use the average caluclated:
  print "Result: $(ema.average)"
