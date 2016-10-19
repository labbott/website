---
date: 2016/10/19 11:00:00
title: Fedora kernel scripting
categories: fedora
---
When I joined the Fedora kernel team about 1.5 years ago, I was the first brand
new person in a long time. My teammates had most of the infrastructure
instructions for the kernel in their brains. Part of my new hire tasks were
[documenting](https://fedoraproject.org/wiki/Kernel/DayToDay) the steps for
working with the Fedora kernel. These days, I can do most of the day to day
tasks in my sleep. The tasks are still somewhat manual though which leaves
room for error. I've decided to correct this by scripting some of the more
manual parts.

Most of the daily rawhide work is taken care of by a [script](http://pkgs.fedoraproject.org/cgit/rpms/kernel.git/tree/scripts/generate-git-snapshot.sh)
to generate a diff between the last kernel tag and the current master. There
are still a bunch of manual steps that need to happen for a successful commit.
The rough steps are: update the snapshot tree to master, run the
`generate-git-snapshot.sh` script, delete the old snapshot from `sources` and
upload the sources. I have forgotten all of those manual steps at one time or
another, resulting in failed builds, extra sources being downloaded, or
incorrect snapshots.

The `generate-git-snapshot.sh` script is not designed to
be run when master is at a tagged -rc, there are a different set of steps
for -rcs: Download the -rc tarball from kernel.org, upload it, remove old
patches from the `sources` file, adjust variables in the kernel.spec
accordingly. Once again, I have screwed up these steps at one time or another,
resulting in failed or bad builds.

For most rawhide releases, debugging options are enabled. This is designed to
help catch more issues since rawhide kernels are a big more experimental (but
still very usable!). For -rc tagged releases, we turn off debugging in the
main build. This involves running `make debug` and `make release` as
appropriate. I forget this all the time. The result is that some of the rawhide
snapshots may not have debugging options on for a build or two.

Stable releases are significantly less scripted than rawhide. A stable update
involves downloading the patch from kernel.org, uploading it, removing the
old file from the sources, updating the stable variable in `kernel.spec`, and
adding an appropriate changelog. I most commonly mess up the changelog. I
have managed to type the date incorrectly and also misspell my name in addition
to forgetting to upload the source file.

I wrote scripts to take care of most of the rawhide and stable update steps.
After working out a few bugs in the scripts, they are working great. I
describe these as 'coffeeproof'. Failing any bugs in the script, I should be
able to make rawhide/stable releases before the coffee has kicked in by running
a single command. So have I succeeded in scripting myself out of a job? No,
not quite yet. The scripts do most of the manual setup for a release but
I still have to debug merge conflicts with the existing Fedora patch set.
For rawhide this often takes [actual thought](http://www.labbott.name/blog/2015/11/06/the-work-of-maintaining-a-kernel-tree/).
Stable release often just involve dropping bug fixes for patches we have been
carrying so I have half a mind to see if I can script that even more.
Hopefully all this continues to improve the quality of Fedora releases.
