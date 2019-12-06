---
layout: post
date: 2018/06/01 11:00:00
title: More kbuild for reproducible builds
category: fedora
---
I'm still working on patches to deal with [build ids](https://www.labbott.name/blog/2017/12/04/build-ids-and-the-fedora-kernel/)
for the kernel. One issue I spent way too long figuring out was that if you
just do a basic `make` for the kernel, some local environment information
will be picked up on each build. This means that the build id will not be
the same between builds of the same source tree because the sha1 sum is going
to be different. This has the funny effect of meaning that the problem of
unique build ids is actually solved for the `vmlinux` itself but still not
modules or the vDSO.

Among the list of common commands you learn for Linux is `uname`. If you run
`uname -a` you'll see something like

	Linux localhost.localdomain 4.17.0-0.rc3.git4.1.fc29.x86_64 #1 SMP
 	Fri May 4 19:41:58 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux

What's most interesting for this discussion is a subset with `uname -v`

	#1 SMP Fri May 4 19:41:58 UTC 2018

This is some version information about when this kernel was built. All this
can technically be namespaced but by default these values come from generated
defines at compile time, specifically `UTS_VERSION`. You can see how this gets
generated from [`scripts/mkcompile_h`](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/scripts/mkcompile_h)

The timestamp is fairly obvious and the Kbuild infrastructure provides an
easy override to set it to a fixed value (`KBUILD_BUILD_TIMESTAMP=` some string
that can be passed to `date -d`). A bit more obtuse (at least for me) was
the `#1`. This is a value stored in a file called `.version`. This gets updated
every time `scripts/linux-vmlinux.sh` is run. It is, in fact, designed to
be a release number to differentiate between builds. After too many hours of
debugging it also ends up feeling like some sort of achievement for a video
game ("You have managed to compile the kernel `.version` times while working
on this particular issue.") This can also be set with `KBUILD_BUILD_VERSION`.

The short and sweet summary is that if I actually want to verify things with
build ids I can set `KBUILD_BUILD_TIMESTAMP` and `KBUILD_BUILD_VERSION` to
fixed values to get a consistent build id across compiles. It's worth noting that
modules can end up with a consistent build id without setting anything
extra because they (typically) don't use `UTS_VERSION` anywhere. Now all I
need to do is finish cleaning up some patches.
