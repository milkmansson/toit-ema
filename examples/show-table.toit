// Copyright (C) 2025 Toit Contributors
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import ema show *


main:
  // construct the ema object. Note no alpha is set:
  ema := Ema
  ema.compute-ema-weights-from-alpha .31 --n=20
