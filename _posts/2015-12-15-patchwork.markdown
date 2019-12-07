---
layout: post
date: 2015/12/15 16:00:00
title: Grabbing kernel patches from mailing lists and the internet
category: fedora, kernel
permalink: /blog/2015/12/15/grabbing-kernel-patches-from-mailing-lists-and-the-internet/
---
The kernel community runs on mailing lists. All change sets end up through
one mailing list or another. The mailing list is great for reviewing and
reading changes but eventually the patches need to be tested or pulled into
a tree, for testing or release. Every developer comes up with a workflow
that work for them. Greg KH has a [screencast](https://www.youtube.com/watch?v=6zUVS4kJtrA) showing what he does to apply patches to the stable tree. My
workflow is simpler and less optimized:

- Save the patch from my e-mail client (I mostly use thunderbird)
- Checkout appropriate branch in my kernel tree
- `$ git am <patch path>`

[git am](https://www.kernel.org/pub/software/scm/git/docs/git-am.html) takes
care of most of the hard work of putting the patch into git. Generally the
tree I'm working off of is a local copy of the kernel.org tree. To generate
a patch that can be brought over to the Fedora kerne pkg-git

- `$ git format-patch -1 HEAD`

[git format-patch](https://www.kernel.org/pub/software/scm/git/docs/git-format-patch.html)
again takes care of generating a nice patch file. This is also what I use for
generating patches that are already in a git tree. I'll often add the tree
as a remote to my system:

- `$ git remote add new-repo-name git://url-to-repo`
- `$ git fetch new-repo-name`
- `$ git log` *find commit hash*
- `$ git format-patch -1 <hash>`

Some git web versions will also have a patch download option. For
kernel.org,
`https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=<COMMIT HASH>`
(drop the angle brackets around the commit hash)
will show you the a commit on the kernel master branch which should have a
patch download link (the `commit/?id=<commit hash>` trick should work on
other cgit sites, again dropping the angle brackets around the hash)

If a patch isn't a git tree and you aren't subscribed to the mailing list,
LKML and other spinoffs archive patches through a tool called
[patchwork](http://jk.ozlabs.org/projects/patchwork/).
[patchwork.kernel.org](https://patchwork.kernel.org) has archives for LKML and
a number of other mailing lists.

The number of patches that come in through the
[LKML patchwork](https://patchwork.kernel.org/project/LKML/list/) is the same
as LKML (so quite large). patchwork is not great for searching through all
patches; it's best if you know which patch you are looking for. The easiest
way to find a patch is to use the filter. Right above the list of patch
subjects should be a link 'Filters' which should drop down a menu. I've found
searching by submitter to be the easiest way to find patches (there's auto
completion to help you along). Once you've found the patch subject, the mbox
download link will give you a file that can be applied with `git am`. 

Between kernel.org and a [few](https://patchwork.linuxtv.org/project/linux-media/list/)
 [other](https://patchwork.ozlabs.org) places, most mailing lists should
be covered by patchwork. Some will still slip through the cracks though.
At that point, the best option is to find the message on an archive somewhere
and look for a link to download the raw message. You can also be brave and
copy and paste the message into a file and fix up any whitespace mangling
yourself. Once you've done this, you'll understand why maintainers hate
getting patches that don't apply or are whitespace damaged. 

Again, as I mentioned at the beginning every developer has their own workflow.
I'm sure others can find ways to improve this flow. The goal here is to give
an idea about how to produce patch files from patches others have made
available. 
