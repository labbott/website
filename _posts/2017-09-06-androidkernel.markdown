---
layout: post
date: 2017/09/06 11:00:00
title: Kernels need updates, no really
category: fedora
---
Google has been announcing new details about its next Android release, Oreo.
One of the items that came out is a new requirement for a
[minimum kernel version](https://www.xda-developers.com/google-mandating-linux-kernel-versions-android-oreo/).
SoC manufacturers must now use a kernel that is greater than 4.4, one of the
[long term stable (LTS)](https://www.kernel.org/releases.html) kernels
maintained by Greg Kroah-Hartman. Android has
long prided itself on differentiation and given device makers a lot of latitude.
This has not infrequently led to fragmentation and difficulties with device
upgrades. Google has started to work towards fixing this with efforts like
[project treble](https://android-developers.googleblog.com/2017/05/here-comes-treble-modular-base-for.html).

One aspect that many people like about mandatory kernel versions is increased
security. The argument is that newer kernel versions already have all the
security fixes and features so they are going to be more secure. This is true,
to a degree. Kernel 4.4.x should cover everything 3.18.x did plus more. The
problem with this argument is that the kernel does not stop updating. A
a mandatory kernel version ensures a base layer of protection but will not
protect against new threats. A newer kernel will make it easier to apply fixes
but this involves the device maker actually pushing out updates. Requiring a
4.4.x kernel isn't going to help against StackCowBleed if your device never
gets the update. Mandating a newer kernel version isn't going to make device
updates easier if you have to deal with [a million lines](https://www.youtube.com/watch?v=JnGL85SglbA)
of out of tree code either.

A move towards a standard for kernels is a step in the right direction for
the Android ecosystem. This needs to be coupled with a continual effort to
get code upstream and deliver regular updates though. Hats off to the Android
team and device makers who continually work to make this better.

