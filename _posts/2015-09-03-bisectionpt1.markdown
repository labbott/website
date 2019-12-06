---
layout: post
date: 2015/09/03 16:00:00
title: Bisection, part 1
category: fedora
---
(This was originally going to be a post on the pains of scripting
bisection but the background on the importance of bisection turned out
to be long enough)

One of the most frustrating parts of Fedora kernel engineering is dealing
with bugzilla reports. Debugging is one of my favorite parts of software
development but in order to debug I need something I can actually debug.
Less obtusely, lots of the bug reports that come in are system specific.
I can't just grab the hardware and poke at it until I understand the bug.
My debugging strategies are limited to some combination of 1) hoping upstream fixed
something already 2) hoping the crash is in a part of the code I actually
know something about 3) staring at the crash and coming up with something
more than "yes, that is definitely a kernel panic 4) sending the report
to LKML 5) ignoring the problem and hope someone else decides to fix it.
Some of these strategies are more likely to get the bug fixed than others.

One thing that can make it a lot easier to get bugs fixed is (correctly)
identifying when the problem started happening. If the hardware/feature
has never worked under Linux, the solution may range from adding a few
device ids to writing a brand new driver. If the system once worked but
now doesn't, it's just a matter of identifying what broke it. Easier
said than done though. Major upgrades (4.x -> 4.y) are a common
place where things break. There can be well over 10000 commits across the
entire tree. Even a subsystem can have hundreds of commits and good
luck if someone did a major refactoring of the code.

Sometimes you can get lucky and guess which commit to back out. Sometimes
you waste two days trying commits from the subsystem and then find out
the actual cause is elsewhere. For more systematic debugging,
[git bisect](http://git-scm.com/docs/git-bisect/1.7.7) is a magical tool. The idea
behind git bisect is that each commit is either correct or not correct.
If you have a known good and bad commit it should be possible to figure
out which commit actually broke the build. [Binary search](https://en.wikipedia.org/wiki/Binary_search_algorithm)
will put the number of commits to test at roughly log_2(number of commits
between good and bad).

There are lots of tutorials on git bisect out there but at a high level,
suppose you have an issue that showed up between kernel versions 4.0 and
version 4.1. Clone a copy of the kernel git tree.
`git bisect start v4.1 v4.0`
to setup the tree to test. Compile and run whatever tests are necessary.
if the tests pass do
`git bisect good`, if not `git bisect bad`. If you can't give an answer
because of a broken build, do
`git bisect skip` .
Repeat this process until git bisect spits out what commit broke the
build based on your bisect. Once you get an answer, the best way to
verify the bisect was correct is to revert the commit in your tree
and see if the problem is gone.

Bisection works better for some problems than others. If the problem
is intermittent when running, bisection will probably result in 
false positives. Long test runs can be an issue without dedicated
time and resources. If changing random code makes the problem
go away I weep for you. Bootup problems are usually good candidates
for bisection. Hardware that doesn't work at bootup is also usually
bisectable. "My laptop wifi sometimes stops working" can be bisected
but it takes some persistence.

Even if a bug is a good candidate for bisection, people may not want
to do a bisect. People can be intimidated doing things related to the kernel.
If you aren't familiar with git and bisect already, performing a bisect
can seem daunting. The hardware that people may be reporting the issue
on may be critical so down time of rebooting each time may not be plausible.
Sometimes the reason people don't want to do a bisect is because they
just don't want to do a bisect. I am completely guilty of this at times.

The real challenge is figuring out the scale of "How much do I want
this bug fixed" to "How likely is this bug to get fixed if I don't
do a bisect". For another axis, bisection is incredibly valuable to the
kernel and telling people to bisect is a very common request upstream.
Even the experts in the subsystem need help in breaking down a problem
and may not have access to the exact setup to reproduce the issue.
Nobody in the kernel community likes regressions and posting with
"Commit X causes a regression" stands a very good chance of getting
a useful response, especially if the regression is some kind of crash.

In a future wall of text, I'll describe some of the issues with trying
to make bisection work with Fedora kernels.
