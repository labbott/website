---
layout: post
date: 2019/01/10 11:00:00
title: Kernel numbering and Fedora
category: fedora
---
By now it's made the news that the kernel version has jumped to [version 5.0](https://lwn.net/Articles/776102/).
Once again, this numbering jump means nothing except Linus decide that he
wanted to change it. We've been through versioning jumps before (2.6 -> 3.x,
3.x -> 4.x) so practically we know how to deal with this by now. It still takes
a bit of hacking on the kernel packaging side though.

Fedora works off of a package git (pkg-git) model. This means that the primary
trees are not git trees of the actual source code but git trees of a spec file,
patches, and any other scripts. The sources get uploaded in compressed archive
format. For a stable fedora release (F28/F29 as of this writing), the sources
are a base tarball (`linux-4.19.tar.xz`) and a stable patch on top of that
(`patch-4.19.14.xz`). Rawhide is built off of Linus' master branch. Using 4.20
as an example, start with the last base release (`linux-4.19.tar.xz`), apply
an -rc patch on top (`patch-4.20-rc6.xz`) and then another patch containing
the diff from the rc to master on that day (`patch-4.20-rc6-git2.xz`). We
have scripts to take care of grabbing from kernel.org and generating snapshots
automatically so kernel maintainers don't usually think too much about this.

When there's a major version bump, most of our scripts break. This isn't just
a matter of doing `s/4/5/`. Because the major version bump happens randomly,
we can't easily script "if minor version == XXX pickup y as base". This means
our existing code doesn't know how to pick up `linux-4.20.tar.xz` as a base
and apply `patch-5.0-rc1.xz` on top of that. Because we've dealt with this
before, other people have come up with the easiest solution which is a
combination of hardcoding and using the full -rc tarball. This means that
our base is `linux-5.0-rc1.tar.xz` and we generate snapshots on top of
that (`patch-5.0-rc1-git3.xz`).

The kernel.spec and associated scripts look a bit hacked up at the moment.
This is only for the next 6 weeks though, after which we will go back to
our usual methods. All credit for this scheme goes to the maintainers before
me.
