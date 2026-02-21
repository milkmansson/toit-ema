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
  logger_/log.Logger          := ?
  alpha_/float?               := null  // the tuning knob: 0 < alpha <= 1
  average_/float?             := null  // this value contains the moving average
  steps_/int                  := 0     // this value counts the added values
  last-used-n_/int            := 10
  quiet_/bool                 := false
  warmed-threshold-steps_/int := 0

  /**
  Constructs an instance of the object, with an alpha value set.

  If coverage is given, sets the steps required to reach readiness.  Readiness tested using `$is-warmed`
  */
  constructor
      alpha/float
      --coverage/float?=null
      --quiet=false
      --logger/log.Logger=log.default:
    assert: 0 < alpha <= 1.0
    logger_ = logger.with-name "ema"
    set-alpha alpha
    quiet_ = quiet
    if (coverage != null):
      assert: 0 < coverage <= 1.0
      set-required-coverage coverage

  /**
  Constructs the object.  Alpha can be set later, but must be set before use.
  */
  constructor
      --quiet=false
      --logger/log.Logger=log.default:
    logger_ = logger.with-name "ema"
    quiet_ = quiet
    if not quiet_:
      logger_.warn "constructor: ema alpha must be set before use."

  /**
  adds a new value to the ema.

  Use the `--log` switch to print a status for each add.
  */
  add x/any --log=false -> none:
    if alpha_ == null:
      logger_.error "add: error: alpha not set."
      return

    xf/float := (x is int) ? x.to-float : x

    if average_ == null:
        average_ = xf
        //logger_.debug "add: initialised with value $(%0.3f x) (pos $steps_ + 1)"
    else:
        average_ = (1.0 - alpha_) * average_ + alpha_ * xf
        //logger_.debug "add: added value \t$(%0.3f x) \t(pos $steps_ + 1)  \t Average: $average_"
    steps_ += 1
    if log:
      print "[ema] INFO: add [$(%03d steps_)]: x=$(%0.4f xf) \t avg=$(%0.4f average_)"

  /**
  resets the ema.

  The existing alpha is left as it is.
  */
  reset -> none:
    average_ = null
    steps_ = 0

  /**
  Sets the alpha value.  (0 < alpha <= 1.0)

  Note: changing the alpha value after some data is collected means the EMA
    becomes a 'piecewise exponential weighting' with discontinuity at the moment
    the alpha is changed.  This means the 'weights' of the older samples (their
    influence on the current average) no longer follow a clean exponential
    curve, and the average is no longer an 'average'.

  A legitimate use for this is where a large number of samples are required before
    there are enough samples for the target alpha, but waiting for them is not
    possible.  Therefore this function does not prevent changing the alpha after
    values have been added, and the user is advised to consider this.
  */
  set-alpha alpha/float -> none:
    assert: 0 <= alpha <= 1.0
    if (alpha == 0.0):
      logger_.warn "set-alpha: alpha of 0.0 remoevs alpha.  Resetting. Must be set before use."
      alpha_ = null
    if steps_ > 0:
      if not quiet_: logger_.warn "set-alpha: ema changing after getting samples - read README.md."
    alpha_ = alpha
    //logger_.debug "set-alpha: New alpha set." --tags={"alpha" : alpha_}

  /**
  Gets the alpha value.  (0 < alpha <= 1.0)

  See $set-alpha
  */
  get-alpha -> float?:
    return alpha_

  /**
  Whether the alpha value is set.

  See $set-alpha
  */
  is-alpha-set -> bool:
    if alpha_ == null: return false
    if alpha_ > 0.0: return true
    return false

  /**
  Returns current coverage (0.0 < percent < 1.0)

  Computed given the current number of number of samples and the current alpha.
    If values are given, will calculate coverage for the given values.
  */
  coverage alpha/float?=alpha_ --steps/int?=steps_ -> float:
    if alpha == null:
      logger_.warn "coverage: alpha not set. Must be set before use."
      return 0.0
    if steps == null: steps = 1
    value := 1.0 - (math.pow (1.0 - alpha) steps)
    value = clamp-value_ value --lower=0.0 --upper=1.0
    return value

  /**
  Sets threshold (steps) for desired coverage.

  This method sets the number of samples required to meet the % coverage, and is
    compared every time (`is-warmed`) is evaluated.  Minimum steps are cached
    instead of doing the log math in $coverage every time the test (`is-warmed`)
    is evaluated.
  */
  set-required-coverage percent/float --alpha/float?=alpha_ -> none:
    assert: 0 < percent <= 1.0
    if alpha == null:
      logger_.error "steps-for-coverage: alpha not set."
      return

    required-steps/int := 0
    if alpha == 1.0:     // first sample gives full coverage
      required-steps = 1
    else:
      required-steps = ceil_ ((math.log (1.0 - percent)) / (math.log (1.0 - alpha)))

    //logger_.debug "set-required-coverage: percent coverage requres: " --tags={"percent":percent,"required-steps":required-steps}
    warmed-threshold-steps_ = required-steps

  /**
  Returns true if the desired coverage has been reached.
  */
  is-warmed -> bool:
    return steps_ >= warmed-threshold-steps_

  /**
  returns the current average value in the ema.

  Returns null if no alpha is set.
  */
  average -> float?:
    if alpha_ == null:
      logger_.error "average: error: alpha not set."
      return null
    return average_

  /**
  Returns the number of values seen by the moving average so far.

  Information only: Increments by 1 every time $add is called.
  */
  samples -> int:
    return steps_

  /**
  function to help calculate an alpha value given a sample window.

  - Use the `--set` flag to set the calculated example as the new alpha value.
  - Use the `--table` flag to have it print a table of the results.  See
    $compute-alpha-from-coverage.
  */
  compute-alpha-from-window samples/int --table/bool=false --set/bool=false -> float:
    if samples < 1: return 1.0
    computed-alpha := 2.0 / (samples + 1)
    if table: compute-ema-weights-from-alpha computed-alpha
    if set: set-alpha computed-alpha
    return computed-alpha

  /**
  function to help calculate an alpha value given a half life.

  - Use the `--set` flag to set the calculated example as the new alpha value.
  - Use the `--table` flag to have it print a table of the results.  See
    $compute-alpha-from-coverage.
  */
  compute-alpha-from-halflife samples/int --table/bool=false --set/bool=false -> float:
    if samples <= 0: return 1.0
    computed-alpha := 1.0 - (math.pow 0.5 (1.0 / samples))
    if table: compute-ema-weights-from-alpha computed-alpha
    if set: set-alpha computed-alpha
    return computed-alpha

  /**
  function to help calculate an alpha value given a number of samples and percent.

  - Use the `--set` flag to set the calculated example as the new alpha value.
  */
  compute-alpha-from-coverage samples/int --coverage/float --set/bool=false -> float:
    assert: 0 < coverage <= 1.0
    if samples <= 0: return 1.0
    computed-alpha := 1.0 - (math.pow (1.0 - coverage) (1.0 / samples))
    if set:
      set-alpha computed-alpha
      set-required-coverage coverage
    return computed-alpha

  /**
  function to show the effect of an alpha.

  Example: Caluclate the alpha for 30 samples, with ALL older values not
    accounting for more than 15% of the average.  Set the value ready for use
    in the object:
  ```
  ema := Ema
  ema.compute-ema-weights-from-alpha .31 --n=20
  ```

  This example prints the n'th sample number vs, its weight in the average, and
    a running total - at sample 11, all later/older values only account for just
    over 1%. The 20th sample now has .05% weight in the present calculation. The
    result will look like:
  ```
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
  compute-ema-weights-from-alpha alpha/float=alpha_ --n/int=last-used-n_ -> none:
    if last-used-n_ != n: last-used-n_ = n
    running-total/float := 0.0
    for k := 0; k < n; k += 1:
      weight := alpha * (math.pow (1.0 - alpha) k)
      running-total += weight
      print "$(%02d k + 1): \t$(%2.5f weight * 100)% \t (total $(%0.5f running-total * 100)%)"

  /**
  Clamps the supplied value to specified limit.
  */
  clamp-value_ value/any --upper/any?=null --lower/any?=null -> any:
    if (upper != null) and (lower != null):
      assert: upper > lower
    if upper != null: if value > upper:  return upper
    if lower != null: if value < lower:  return lower
    return value

  /**
  Returns the absolute value of x
  */
  abs x/any -> any:
    if x is int:
      x < 0 ? return (x * -1) : return x
    if x is float:
      x < 0.0 ? return (x * -1.0) : return x

    logger_.error "abs: don't know how to deal with variable type." --tags={"value":x}
    throw "abs: don't know how to deal with variable type."
    return 0.0

  /**
  Returns the maximum of the set of values.
  */
  max-of_ values/List -> any:
    candidate/any := null
    values.do:
      if candidate == null: candidate = it
      if it > candidate: candidate = it
    return candidate

  /**
  Returns the minimum of the set of values.
  */
  min-of_ values/List -> any:
    candidate/any := null
    values.do:
      if candidate == null: candidate = it
      if it < candidate: candidate = it
    return candidate

  /**
  Rounds the given value up to the nearest integer.
  */
  ceil_ x/float -> int:
    i := x.to-int        // truncates down
    return (x > i.to-float) ? (i + 1) : i

  /**
  Rounds the given value down to the nearest integer.
  */
  floor_ x/float -> int:
    i := x.to-int
    return (x < i.to-float) ? (i - 1) : i
