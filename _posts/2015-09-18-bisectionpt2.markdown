---
layout: post
date: 2015/09/18 16:00:00
title: Bisection, part 2
category: fedora
permalink: /blog/2015/09/18/bisection-part-2/
---
As described before, bisection works by taking a series of commits and
testing systematically to find which commit introduced the regression. This
doesn't match well with the current development model of the Fedora kernel
and makes bisection difficult.

The kernels that are released for Fedora are what's available on
[kernel.org](http://kernel.org) plus a smattering of extra patches. These
patches range from fixes that are not yet merged into the release to (very)
select patches for new features. This means the tree looks like

```
U1 -> U2 -> U3 -> ... UN-> F1 -> F2 -> ... -> FN
```

Where U commits are from upstream and F commits are from Fedora. Suppose there
is a bug somewhere in this tree. How do you bisect? Naively, you could take
U1 as the good commit and FN as the bad commit and bisect from there. The
problem there is that as you test any of the upstream commits you lose the
features Fedora is adding. You might as well just bisect on the kernel.org
tree directly and ignore Fedora patches completely.

Given the number of bugzilla repots, people seem to want the Fedora patches
and not just kernel.org sources so there needs to be a way to combine the
two together. One possibility is to do a bisect on the upstream tree and
then replay the Fedora patches at every bisect step.
This means the tree may look like

```
U1 -> U2 -> ... -> U_a -> F1 -> F2 -> ... -> FN
```

at one step and then

```
U1 -> U2 -> ... -> U_b -> F1 -> F2 -> ... -> FN
```

at another step. Seems workable. Getting the upstream tree is easy but where
do the Fedora patches come from?

Fedora packages are stored in git but they aren't stored in an exploded tree
form. It's essentially a .spec file, a series of patches, and a few scripts.
My teammate [Josh Boyer](http://jwboyer.livejournal.com/50453.html)
talked about some of the problems with trying to maintain an exploded tree
for our day to day work and why we aren't doing so any more. The pkg-git repo
isn't nicely tagged so there's some degree of manual work to go checkout the
state of patches at a particular release. An exploded tree
is really useful for tasks like this. Fortunately, there is a pseudo
substitue: an actual git tree of releases is present on kernel.org with nice
git tags. This makes it easy to grab the set of Fedora patches that were
present in a particular release.

The next question is what patches are being replayed at each step. The
set of patches for a particular release will apply cleanly but another commit
may introduce conflicts on those patches; between the 100s or 1000s of upstream
commits coming in patches may drop out or need to be adjusted. Since the point
of bisection is to test the commits between releases, there needs to be a
way to get a set of commits which will apply cleanly to a single commit. The
closest I've been able to get to this is to grab a close rawhide commit and
try the patches there. This has been somewhat successful.

Assuming you can actually get a set of patches that will apply, the next step
is actually building a kernel that can be installed. Just going into a kernel
directory and doing 'make && make modules_install && make install' certainly
works but again gets away from the advantages of Fedora. Everyone loves an
RPM! The existing RPM generation for the kernel is complex. The
[kernel.spec](https://fedoraproject.org/wiki/Kernel/Spec) file is
layers and layers of macros and scripts to generate several different packages.
There are also config files for kernel options. A change to any one of these
parts may result in something that's not backwards compatible. Since there
are no tags in the pkg-git repo, there's no grabbing a file from a particular
release. This means any spec file used needs to be generic enough to handle
an aribtrary kernel snapshot. Taking the metaphorical hacksaw to the
kernel.spec, it is possible to generate something that takes a kernel tar ball
and spits out an rpm.

So is bisection on the Fedora kernel actually possible? Probably. I've been
slowly working on scripts to do so. I made a
[first attempt](https://pagure.io/fedbisect) which doesn't spit out RPMs and
is probably over simplified for most cases. I've been working my way through
a set of scripts that are smarter about conflicts and spit out an RPM. I
may post those early if I can get to a good snapshot point.

I'm still not sure if this is actually new work or if I'm reinventing the
wheel. 
