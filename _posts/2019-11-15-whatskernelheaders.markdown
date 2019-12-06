---
layout: post
date: 2019/11/15 11:00:00
title: What's a kernel headers package anyway
category: fedora
---
I've written [before](https://www.labbott.name/blog/2018/06/21/what-s-a-kernel-devel-package-anyway/)
about what goes into Fedora's `kernel-devel` package. Briefly, it consists
of files that come out of the kernel's build process that are needed to
build kernel modules.

In contrast to `kernel-devel`, the headers package is for userspace programs.
This package provides `#defines` and structure definitions for use by
userspace programs to be compatible with the kernel. The system libc
comes with a set of headers for platform independent libc purposes (think
printf and the like) whereas the kernel headers are more focused on providing
for the kernel API. There's often some overlap for things like system calls
which are tied to both the libc and the kernel. Sometimes the decision to
support them in one place vs the other comes down to [developer choices](https://lwn.net/Articles/799331/).

While the in-kernel API
is not guaranteed to be stable, the userspace API must not be broken. There
was an [effort](https://lwn.net/Articles/507794/) a few years ago to have
a strict split between headers that are part of the userspace API and those
that are for in-kernel use only.

Unlike how `kernel-devel` gets packaged, there are proper make targets
to generate the kernel-headers (thankfully). `make headers_install` will
take care of all the magic. These headers get installed under `/usr/include`

Related to `kernel-headers` is `kernel-cross-headers`. They are called
cross because <strike>using them makes you grumpy and cross</strike> they are designed
for building on another target than your native architecture. A classic
example is ARM embedded system where building anything would be dreadfully
slow, if possible at all. Josh Boyer originally wrote the cross-headers
package with a [nice explanation](https://src.fedoraproject.org/rpms/kernel/c/f65f3f11ac03d07551854cc00886f7314a5ac330)
of why we want such a package (spoiler: packaging toolchains is a nightmare,
cross toolchains doubly so). Because there isn't a standard way to
package this, we end up combining the `make headers_install` target with
each architecture to generate a copy of the headers under `/usr/$ARCH-linux-gnu/`

One of the changes that Fedora made a few years was to split out
`kernel-headers` into a separate repo. This was done for a handful of reasons
but notably it was done to reduce unnecessary rebuilds. If there are no
changes to anything in the uapi directory, there is no need to rebuild. The
result is that in Fedora you may not see a `kernel-headers` package for every
version. This sometimes gets reported as a bug by end users but there should
be no issue since the uapi headers are not versioned. This is in contrast
to the devel package which _is_ versioned per-kernel and _must_ get rebuilt
each time to ensure modules can be built against the correct kernel.

If you don't see a new `kernel-headers` package for a stable kernel update,
it's probably not a bug. If you can identify a specific reason why you think
the headers need to be rebuilt (i.e. the kernel maintainers missed a change),
please file a bug.
