---
date: 2016/02/02 16:00:00
title: I hate benchmarking
categories: fedora
---
Among development tasks, one of my least favorite is benchmarking and I tend
to procrastinate on it (by writing blog posts, for example). Allow
me to enumerate some reasons why I hate doing benchmarking.

- Almost anything can be a benchmark if you believe it is one.

- Benchmarks often conflict with each other. Improve one, another goes down.

- Benchmarks are often used to convince people of something. Combining the
points above, this involves picking your favorite benchmark that moves in
the right direction and then hoping it doesn't move someone else’s favorite
benchmark in the opposite direction.

- Sometimes it's hard to come up with a benchmark to show your code is
actually doing anything. Is the code not actually having any effect or
is the benchmark wrong?

- Some benchmarks come as part of their own framework which means you need
to set that up to get any data.

- Benchmarks inevitably take time to run which either ends up with me staring
at a screen waiting for a benchmark to finish or half-heartedly working on
another task. The same gripe applies for compiling but now I'm waiting on
compiling AND benchmarking.

- Once the benchmark actually finishes, how do you interpret the result? Is
the benchmark consistent if you run it multiple times?

During my recent foray into benchmarking I ended up having to write this code
to figure the results what I was seeing:

	#!/bin/sh
	CNT=100
	mean=0.0
	M2=0.0
	for i in $(seq 1 $CNT); do
		r=`your_favorite_benchmark`
		d_calc="$r-$mean"
		d=`echo $d_calc | bc -l`
		mean_calc="$mean+($d/$i)"
		mean=`echo $mean_calc | bc -l`
		M2_calc="$M2+($d*($r-$mean))"
		M2=`echo  $M2_calc| bc -l`
	done

	echo "mean $mean"
	V_calc="$M2/$(($CNT-1))"
	V=`echo $V_calc | bc -l`
	DEV_calc="sqrt($V)"
	DEV=`echo $DEV_calc | bc -l`
	echo "variance $V"
	echo "stdev $DEV"


This is what gets me about benchmarking. I always feel as if I get side tracked
by having to jump through all kinds of different hoops just to get a meaningful
result. Debugging crashes always seems more straight forward to me (“Did you
fix the crash? Did you fix the crash in a reasonable way? Good job!”). Debugging
benchmark issues always feels like a slog (“Okay where is it slowing down. Time
to guess what to look at with ftrace. Wait this slows down something else”).
None of this complaining should be taken as saying that benchmarks aren't
valuable, or that I can't do it. Everyone has stuff that they find particularly
tedious to deal with and one of those for me is benchmarking.
