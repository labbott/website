---
layout: post
date: 2015/11/06 16:00:00
title: The work of maintaining a kernel tree
category: fedora, kernel
permalink: /blog/2015/11/06/the-work-of-maintaining-a-kernel-tree/
---
As mentioned in the previous discussion on bisection, Fedora maintains a 
series of patches on top of the kernel.org kernel (Kernel jargon:
if you here something referred to as "vanilla kernel" it's referring to a
kernel from kernel.org without any additional patches). The patch count for
rawhide as of this post was ~50. In a previous job, the [trees](http://static.lwn.net/images/conf/2015/klf-ks/bird-slides.pdf) 
I worked on had ~20,000 patches and over 1 million lines of code difference
from vanilla. I was significantly less hands on with the maintenance of that
1 million line tree but I still observed how it did and didn't scale.
These certainly represent some of the extremes of trees but ultimately the
tasks need to be done to maintain those tree even if how they happen can
vary.

Adding a patch that was written for a tree specifically is one of the easier
tasks. For Fedora, one of the maintainers copies the patch into the pkg-git
directory, updates the spec file, and pushes the git branch. This works for
Fedora because we have a relatively low rate of patches coming in directly.
As the number of contributors to a tree grows, having individual maintainers
do this work becomes harder and harder. Maintainers now have to do this work
multiple times and make sure the individual patches that are being merged
don't conflict with each other. One solution can be to switch to a continuous
integration system coupled with a review system like
[gerrit](https://www.gerritcodereview.com). Of course, then you need people
to do the work of maintaining that CI system. (Running a CI system can be
a thankless job. Thank you to all who do this work. Have you thanked your
DevOps today?) 

Inevitably, it will be necessary to bring in a patch or feature that wasn't
written against your branch. Backport time! Sometimes the feature will apply
cleanly to the branch without any conflicts. Commonly though, patches will
not and then the maintainer needs to figure out what to do. Conflict resolution
requires thought about the code. The thoughts that are going through my head
when I'm trying to do a backport include:

	- Which part of the code has the conflict?
	- What's actually changed to introduce the conflict?
	- Is this a feature addition or a bug fix?
	- Am I dropping parts of the code? If so, what am I dropping?
	- Is this changing code flow? structures? #defines?
	- Can I take both parts? Just one? Which one?
	- Will this change affect any other parts of the code base?
	- What is the patch I'm trying to apply actually doing?

That last point is the most important. Individuals who are working on backports
need to have some degree of familiarity with the the code base. Without that
familiarity, it's difficult to ensure that the applied patch is still doing
the same thing.  Even
with familiarity it's still easy to get wrong (I once did a backport
improperly and introduced a page accounting bug that went unnoticed for
months). The bigger the difference between the patch base and tree, the more
work is required to bring it in. Backports are necessary but are not cheap
or risk free.

Eventually the time may come to bring a branch to a new kernel version. The
ultimate goal is to have a tree on the kernel you want with the features you
want with the git history you want. This leaves a lot of options open as to
how you produce a tree which meets those requirements. If you're lucky, some
of the patches in the tree will already be present in the new kernel which
means they no longer need to be maintained. Inevitably, some of the patches
are not yet upstream which means that conflicts for each patch/file must
be worked through via the backport logic. Once all conflicts are resolved,
new features in the kernel need to be evaluated. A Fedora major rebase can take
about a day or two depending on conflicts and the type. Rawhide typically takes
an hour or two during the merge window, less during -rc times.
A tree with lots of out of tree patches and drivers can take weeks to get
compiling and then more weeks to test and verify.

What's the conclusion here? Maintaining kernel trees and branches takes
developer effort and time. This work can easily fill a full time job. 
Getting code into the mainline reduces some of
the maintenance burden for upgrading to a new kernel version. For some trees
though there may always be patches which need to be carried. Ultimately, branch
work is a trade off of changing the code base for features/fixes vs. not
changing and spending that development time elsewhere. For companies that
have their own trees, throw in some buzzwords when having this discussion
("business need", "value add", "deliverables", "customer ask", "resources").
The two sides are constantly at odds and it only gets worse the older the branch
gets. Human problems are the hardest to solve in technology.
