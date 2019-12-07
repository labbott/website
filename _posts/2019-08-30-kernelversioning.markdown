---
layout: post
date: 2019/08/30 11:00:00
title: Petty gripes about kernel versioning and tarballs
category: fedora
permalink: /blog/2019/08/30/petty-gripes-about-kernel-versioning-and-tarballs/
---
Today in gripes that about 5 people including me will have: it's really
difficult to find a unified way to get a tarball from something on kernel.org
to the Fedora dist-git in a way that meets the Fedora packaging guidelines.

Let's start with my pettiest gripe: the lack of a trailing 0 on official
releases. Official kernel releases are usually versioned like 5.1, 5.2. Note
the lack of a trailing 0 there. Stable updates are 5.2.3, 5.2.3 etc. This
would be okay except for if you look at the [Makefile](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Makefile?h=v5.2)
for stable releases, there's still a 0 in the SUBLEVEL filed where stable
updates come from. "But Laura, there's macros to take care of that" yes, in
the kernel itself. I'm working on going from the kernel to dist-git so this
means I'm writing scripts which have to re-do this work and think about this
when generating a version string. If I wanted to be _really_ petty, I'd
start a conversation about changing the kernel versioning completely. The
5.0 numbering means nothing. The bump from 4.x to 5.x was because the second
number was getting to high. The numbers mean nothing at this point except
they keep getting larger. I'd love to see the numbers correspond to a date
since the kernel is basically on a time base release at this point anyway.

Fedora has [packaging guidelines](https://docs.fedoraproject.org/en-US/packaging-guidelines/)
describing how packages should work. It's to the benefit of everyone to follow
these guidelines. The guidelines for [Source](https://docs.fedoraproject.org/en-US/packaging-guidelines/SourceURL/)
recommend using tarballs and give a few other suggestions for how to set
Source0 appropriately.

The Fedora kernel generates 3 types of kernel releases: official releases
(v5.2, v5.2.1), rc releases (v5.3-rc6), and snapshots that don't correspond
to an official tag. Currently, the way we generate all these is starting
with the base (e.g. 5.2) and then applying a patch on top of it (patch-5.3-rc6,
patch-5.2.10). We do this by grabbing the individual tarballs and patches from
kernel.org.

I've been looking at switching Fedora to a src-git for a number of reasons
(I gave a talk at Flock, the video doesn't seem to be up yet). The idea would
be to use the src-git tree primarily and only use the dist-git for generating
the rpm. Because of this, I was looking at switching to single tarballs
instead of the patching model because that matches what the src-git tree
looks like: an upstream tarball plus a bunch of patches. It turns out this
is a pain.

If you look at [kernel.org](https://www.kernel.org/), the -rc tarballs are
generated only from Linus' git tree and not synced to the cdn. That make sense
given -rc tarballs are really only interesting for a week at a time. Except
that means we technically need a different Source0 for -rc and not -rc releases.
Okay, Fedora offers an option to generate an archive from a git url, so
we could just use the git tree. Except stable updates don't come from
[Linus' tree](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/)
they come from [the stable tree](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/).
This means we would end up needing a different Source0 depending on whether
or not we're getting a tarball from a stable tree vs. a base release.

The Fedora guidelines do have a clause for stating you don't have to give
a URL for some circumstances and that could be an option. But the point of
giving a URL is to help with auditing of the package. Maybe you don't trust
these names who push broken updates and can't even spell 'kernel' half the
time so you want to see where the source comes from. This is an important
part of open source and I do think transparency of where tarballs come from
is important.

None of this is a complaint for the kernel.org administrators either. The
kernel.org team does a wonderful job of supporting a variety of needs. This
is just a set of particularly narrow complaints.
