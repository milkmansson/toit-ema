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
  last-n_/int        := 10

  constructor --alpha/float?=null --logger/log.Logger=log.default:
    logger_ = logger.with-name "ema"
    if alpha != null:
      set-alpha alpha
    else:
      logger_.warn "constructor: ema alpha must be set before use."

  /**
  adds a new value to the ema.
  */
  add x/any --log=false -> none:
    if alpha_ == null:
      logger_.error "add: alpha not set."
    if value_ == null:
        if x is int:
          value_ = x.to-float  // initialize on first sample, or require debiasing.
        else:
          value_ = x
        steps_ += 1
        //logger_.debug "add: initialised with value $(%0.3f x) (pos $steps_)"
    else:
        value_ = (1.0 - alpha_) * value_ + alpha_ * x
        steps_ += 1
        //logger_.debug "add: added value \t$(%0.3f x) \t(pos $steps_)  \t Average: $value_"
    if log:
      print "[ema] INFO: add [$(%03d steps_)]: x=$(%0.4f x) \t avg=$(%0.4f value_)"
  /**
  resets the ema.
  */
  reset -> none:
    // Reset the persistent EMA state, leave alpha as it is.
    value_ = null
    steps_ = 0

  /**
  Sets the alpha value
  */
  set-alpha a/float -> none:
    assert: 0 < a <= 1.0
    alpha_ = a
    reset
    logger_.debug "set-alpha: New alpha set." --tags={"alpha" : alpha_}

  /**
  returns the current average value in the ema.
  */
  average -> float?:
    if alpha_ == null:
      logger_.error "add: alpha not set."
      return null
    return value_

  /**
  Returns the number of values seen by the moving average.
  */
  values -> int:
    return steps_

  /**
  function to help calculate an alpha value given a sample window:
  */
  compute-alpha-from-window samples/int --table=false --set=false -> float:
    computed-alpha := 2.0 / (samples + 1)
    if table: compute-ema-weights-from-alpha computed-alpha
    if set: set-alpha computed-alpha
    return computed-alpha

  /**
  function to help calculate an alpha value given a half life:
  */
  compute-alpha-from-halflife samples/int --table=false --set=false -> float:
    computed-alpha := 1.0 - (math.pow 0.5 (1.0 / samples))
    if table: compute-ema-weights-from-alpha computed-alpha
    if set: set-alpha computed-alpha
    return computed-alpha

  compute-alpha-from-coverage samples/int --recent-coverage/float --set=false -> float:
    assert: 0 < recent-coverage <= 1.0
    if samples <= 0: return 1.0           // minimum one sample
    computed-alpha := 1.0 - (math.pow (1.0 - recent-coverage) (1.0 / samples))
    if set: set-alpha computed-alpha
    return computed-alpha

  /**
  function showing weighting for each sample (of n) given alpha value 'a'.

  Prints a table of values of the weightings of the nth sample to help
  understand the weights of samples given the alpha value. See README.md
  */
  compute-ema-weights-from-alpha a/float=alpha_ --n/int=last-n_ -> none:
    if last-n_ != n: last-n_ = n
    for k := n; k > 0; k -= 1:
      w := a * (math.pow (1.0 - a) k)
      print "$(%02d k): \t$(%2.5f w * 100)%"
