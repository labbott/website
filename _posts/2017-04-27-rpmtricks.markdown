---
layout: post
date: 2017/04/27 11:00:00
title: Boring rpm tricks
category: fedora
---
Several of my tasks over the past month or so have involved working with the
monstrosity that is the `kernel.spec` file. The `kernel.spec` file is about
2000 lines of functions and macros to produce everything kernel related.
There have been proposals to split the kernel.spec up into multiple spec files
to make it easier to manage. This is difficult to accomplish since everything
is generated from the same source packages so for now we are stuck with the
status quo which is roughly macros all the way down. The wiki has a
[good overview](https://fedoraproject.org/wiki/Kernel/Spec) of what all goes
into the `kernel.spec` file. I'm still learning about how RPM and spec files
work all the time but I've gotten better at figuring out how to debug problems.
These are some miscelaneous tips that are not actually novel but were new to
me.

Most .spec files override a set of default macros. The default macros are
defined at `@RPMCONFIGDIR@/macros` which typically gets expanded to
`/usr/lib/rpm/macros`. More usefully, you can put `%dump` anywhere in your
spec file and it will dump out the current set of macros that are defined.
While we're talking about macros, be very careful about whether to check if
a macro is undefined vs. set to 0. This is a common mistake in general but
I seem to get bit by it more in spec files than anywhere else.

Sometimes you just want to see what the spec file looks like when it's
expanded. `rpmspec -P <spec file>` is a fantastic way to do this. You can
use the `-D` option to override various macros. This is a cheap way to see
what a spec file might look like on other archictectures (Is it the best way
to see what a spec file looks like for another arch? I'll update this with
a note if someone else me another way).

One of my projects has been looking at debuginfo generation for the kernel.
The kernel invokes many of the scripts directly for historical reasons. Putting
`bash -x` before a script to make it print out the commands makes it much
easier to see what's going on.

Like I said, none of these are particularly new to experienced packagers but
my day gets better when I have some idea of how to debug a problem.
