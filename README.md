# Exponential Moving Average (EMA) Function for Toit

This method is a _memory-optimised_ way of calculating a simple average.

## Problem
To construct an average, normally we would have to keep a number of values in
memory, add them up, and then divide by how many there are.  ('Linear average'.)
With a larger number of samples, it can take some memory space on some already
memory-constrained devices.  An EMA allows us to compute the average in a moving
total type way, without having to keep a large number of historical values (or
manage their rotation) - at the expense of extra CPU usage at the time the
samples are added.

## Solution
- Provide a function that computes a smoothed average of a value stream using O(1)
memory and O(1) time per sample, avoiding any history buffers.
- Address the problem of relevance - eg, if our linear history was a 10 value
window for our average calculation, the value 11th value would be dropped and
become completely irrelevant.

### Caveats
One could argue that the maths are simple enough to not warrant a library like
this.  If this is your level of skill, please rob what you need, and go for gold.
I needed to do this on a number of projects so decided to make it its own
class - and added some extra to help the next guy.

In addition, there is an excellent class in the main Toit library, called
[Statistics](https://libs.toit.io/statistics/class-OnlineStatistics).  The
docs for this one show that it requires the values to be supplied in a byte
array.  Check it out in case its good for your scenario.  This library seeks
to deal with an unspecified number of integers, floats and other values, whilst
providing some functions to help with configuration.


## Features
### Basic use
For basic use, we must first configure a value for alpha, set it, and then add values and get the running average.  Basic use case:
```Toit
//Import the library
import ema show *

// Instantiate the object:
ema := Ema

// Set the Alpha:
ema.set-alpha 0.37

// Add values:
ema.add 1
ema.add 2
ema.add 3  --log  // Value will be displayed, alongside the average
ema.add 3

// Use the average calculated:
print "Result: $(ema.average)
```
To assist with calculating the alpha, the library provides these functions:

### Alpha Calculation Helper: "Window"
Let's say we want the average to feels like it really only looks at the last '20'
points.  The alpha would be 2 / (20 + 1) = 0.095.  Code:
```Toit
// To calculate approximate 20-point average: alpha = 2/21 = 0.095.
ema := Ema
print ema.compute-alpha-from-window 20

// Alpha value printed
0.095
```

### Alpha Calculation Helper: "Half Life"
Lets say, after H new samples, say 14, we want a sample’s weight to halve: in
this case, alpha would be 1 - 0.5^(1/14)
```Toit
// Caluclate the half-life alpha for 14 new samples, as well as set the value
// of the alpha in the object as well:
ema := Ema
print (ema.compute-alpha-from-halflife 14 --set)

// Alpha value printed
0.048304846989380423317
```

### Alpha Calculation Helper: "Coverage"
Want the last n samples to account for x of total weight (e.g., x=0.85 for 85%)?
```Toit
// Caluclate the alpha for 30 samples, with ALL older values not accounting
// for more than 1% of the present average.  In addition, set the value ready
// for use in the object:
ema := Ema
print (ema.compute-alpha-from-coverage 30 --percent-weight=0.01 --set)

// Alpha value printed
0.00033495508513226024405
```

### Alpha Calculation Helper: Display Results
To make it really clear, this function shows a table for n samples, of the % weight of each sample up to the nth.  Don't supply a value to have it use the objects' current alpha value.  Note that results are not normalised - The sum of all these percentages will not be 100.  The values keep getting smaller as is seen below.  Set n to be as many as is necessary to see the distribution.
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

### Other Examples:
For other use cases please see the examples folder.

## Issues
If there are any issues, changes, or any other kind of feedback, please
[raise an issue](https://github.com/milkmansson/toit-ema/issues). Feedback is welcome and appreciated!

## Disclaimer
- All trademarks belong to their respective owners.
- No warranties for this work, express or implied.

## Credits
- AI has been used for code and text reviews, analysing and compiling data and
  results, and assisting with ensuring accuracy.
- [Florian](https://github.com/floitsch) for the tireless help and encouragement
- The wider Toit developer team (past and present) for a truly excellent product

## About Toit
One would assume you are here because you know what Toit is.  If you dont:
> Toit is a high-level, memory-safe language, with container/VM technology built
> specifically for microcontrollers (not a desktop language port). It gives fast
> iteration (live reloads over Wi-Fi in seconds), robust serviceability, and
> performance that’s far closer to C than typical scripting options on the
> ESP32. [[link](https://toitlang.org/)]
- [Review on Soracom](https://soracom.io/blog/internet-of-microcontrollers-made-easy-with-toit-x-soracom/)
- [Review on eeJournal](https://www.eejournal.com/article/its-time-to-get-toit)
