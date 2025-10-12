// Copyright (C) 2025 Toit Contributors
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import ema show *


main:
  // Caluclate the half-life alpha for 14 new samples, as well as set the value
  // of the alpha in the object as well:
  ema := Ema
  print (ema.compute-alpha-from-halflife 14 --set)
