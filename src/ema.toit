// Copyright (C) 2025 Toit Contributors. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be found
// in the LICENSE file.

import log
import math

/**
Exponential Moving Average (EMA) Implementation.
See README.md
*/

class Ema:
  logger_/log.Logger := ?
  alpha_/float?      := null  // the tuning knob: 0 < alpha <= 1
  value_/float?      := null  // this value persists between calls
  steps_/int         := 0     // this value persists between calls
  last-used-n_/int   := 10

  constructor --alpha/float?=null --logger/log.Logger=log.default:
    logger_ = logger.with-name "ema"
    if alpha != null:
      set-alpha alpha
    else:
      logger_.warn "constructor: ema alpha must be set before use."

  /**
  adds a new value to the ema.

  Use the `--log` switch to print a status for each add.
  */
  add x/any --log=false -> none:
    if alpha_ == null:
      logger_.error "add: alpha not set."
      return

    xf/float := (x is int) ? x.to-float : x

    if value_ == null:
        value_ = x
        //logger_.debug "add: initialised with value $(%0.3f x) (pos $steps_ + 1)"
    else:
        value_ = (1.0 - alpha_) * value_ + alpha_ * x
        //logger_.debug "add: added value \t$(%0.3f x) \t(pos $steps_ + 1)  \t Average: $value_"
    steps_ += 1
    if log:
      print "[ema] INFO: add [$(%03d steps_)]: x=$(%0.4f x) \t avg=$(%0.4f value_)"

  /**
  resets the ema.

  The existing alpha is left as it is.
  */
  reset -> none:
    value_ = null
    steps_ = 0

  /**
  Sets the alpha value.  (0 < alpha <= 1.0)

  Note: changing the alpha value resets the entire ema, including the
  caluclated average.
  */
  set-alpha a/float -> none:
    assert: 0 < a <= 1.0
    alpha_ = a
    reset
    //logger_.debug "set-alpha: New alpha set." --tags={"alpha" : alpha_}

  /**
  returns the current average value in the ema.

  Returns null if no alpha is set.
  */
  average -> float?:
    if alpha_ == null:
      logger_.error "add: alpha not set."
      return null
    return value_

  /**
  Returns the number of values seen by the moving average so far.

  Information only: Increments by 1 every time $add is called.
  */
  samples -> int:
    return steps_

  /**
  function to help calculate an alpha value given a sample window.

  Use the `--set` flag to set the calculated example as the new alpha value.
  */
  compute-alpha-from-window samples/int --table=false --set/bool=false -> float:
    if samples < 1: return 1.0
    computed-alpha := 2.0 / (samples + 1)
    if table: compute-ema-weights-from-alpha computed-alpha
    if set: set-alpha computed-alpha
    return computed-alpha

  /**
  function to help calculate an alpha value given a half life.

  Use the `--set` flag to set the calculated example as the new alpha value.
  */
  compute-alpha-from-halflife samples/int --table=false --set/bool=false -> float:
    if samples <= 0: return 1.0
    computed-alpha := 1.0 - (math.pow 0.5 (1.0 / samples))
    if table: compute-ema-weights-from-alpha computed-alpha
    if set: set-alpha computed-alpha
    return computed-alpha

  /**
  function to help calculate an alpha value given a number of samples and percent.

  Use the `--set` flag to set the calculated example as the new alpha value.
  */
  compute-alpha-from-coverage samples/int --recent-coverage/float --set/bool=false -> float:
    assert: 0 < recent-coverage <= 1.0
    if samples <= 0: return 1.0
    computed-alpha := 1.0 - (math.pow (1.0 - recent-coverage) (1.0 / samples))
    if set: set-alpha computed-alpha
    return computed-alpha

  /**
  function to show the effect of an alpha.

  ```Toit
  // Caluclate the alpha for 30 samples, with ALL older values not accounting
  // for more than 15% of the average.  Set the value ready for use in the object:
  ema := Ema
  ema.compute-ema-weights-from-alpha .31 --n=20

  // prints the n'th sample number vs, its weight in the average, and a running
  // total - at sample 11, all later/older values only account for just over 1%.
  // The 20th sample now has .05% weight in the present calculation.
  01:     31.00000%        (total 31.00000%)
  02:     21.39000%        (total 52.39000%)
  03:     14.75910%        (total 67.14910%)
  04:     10.18378%        (total 77.33288%)
  05:     7.02681%         (total 84.35969%)
  06:     4.84850%         (total 89.20818%)
  07:     3.34546%         (total 92.55365%)
  08:     2.30837%         (total 94.86202%)
  09:     1.59277%         (total 96.45479%)
  10:     1.09901%         (total 97.55381%)
  11:     0.75832%         (total 98.31213%)
  12:     0.52324%         (total 98.83537%)
  13:     0.36104%         (total 99.19640%)
  14:     0.24911%         (total 99.44552%)
  15:     0.17189%         (total 99.61741%)
  16:     0.11860%         (total 99.73601%)
  17:     0.08184%         (total 99.81785%)
  18:     0.05647%         (total 99.87431%)
  19:     0.03896%         (total 99.91328%)
  20:     0.02688%         (total 99.94016%)
  ```
  See README.md for a usage example.
  */
  compute-ema-weights-from-alpha a/float=alpha_ --n/int=last-used-n_ -> none:
    if last-used-n_ != n: last-used-n_ = n
    running-total/float := 0.0
    for k := 0; k < n; k += 1:
      weight := a * (math.pow (1.0 - a) k)
      running-total += weight
      print "$(%02d k + 1): \t$(%2.5f weight * 100)% \t (total $(%0.5f running-total * 100)%)"
