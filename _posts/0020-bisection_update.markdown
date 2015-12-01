---
date: 2015/11/30 16:00:00
title: A look at the kernel bisection scripts
categories: fedora
---
I've been hacking on the bisection scripts for quite some time now.
Things got stalled for a bit in October/November. I introduced
several bugs which caused me to lose multiple days of testing verification so
I took a break and worked on other things to relieve my frustrations.
They are now at the point where they could use some testing besides my own.
Here's a walk through of what I have

F21 is going to be going EOL soon. The current (and final) kernel is
4.1.13-101.fc21. An upgrade to F23 might put you at 4.2.6-300.fc23. Upgrades
between major versions are a common point at which things break. Let's
pretend that something in the kernel broke between those two versions.
Grab a copy of the bisect scripts

	$ git clone https://pagure.io/fedbisect.git
	$ cd fedbisect

This contains the scripts. In order to bisect, we need copies of the git trees.
The bisect scripts will take care of this. Everything will be stored in a
subidrectory. This allows multiple
bisects to be going on at the same time. Each command will take the target
directory as an arguemnt. Generally the form will be `./fedbisect.sh <command>
<target dir>`. For this example, the target name will be `broken-things`. The
first step is to sync the trees

	$ ./fedbisect.sh sync broken-things
	<take a  break while this syncs, it may take a while>

a directory named broken-things is now present. Inside the directory:

	$ ls broken-things/
	bisect-step  kernel  pkg-git  step-0

kernel is a clone of the tree from kernel.org, pkg-git is the fedora
repository. bisect-step and step-0 are part of the state for bisection. To
actually start a bisect between the two kernel versions

	$ ./fedbisect.sh start broken-things 4.2.6-300 4.1.13-101

Note the order, it's bad tag first followed by good tag.
Behinds the scenes, this is setting up the kernel tree to run `git bisect`. If
you look at the kernel tree you will see exactly that:

	$ cd broken-things/kernel
	$ git bisect log
	# bad: [1c02865136fee1d10d434dc9e3616c8e39905e9b] Linux 4.2.6
	# good: [1f2ce4a2e7aea3a2123b17aff62a80553df31e21] Linux 4.1.13
	git bisect start 'v4.2.6' 'v4.1.13'

Now you can build

	$ ./fedbisect.sh build broken-things

This is another command that will take a long time to run. In order for these
scripts to be better than a regular bisect, the patches from Fedora need to
be applied. Figuring out which set of patches to be applied is tricky as noted
previously and brute force is still the best solution. With the exception of
a few commits in the merge window, most commits will build but if for some
reason no appropriate patches can be found, an RPM will be generated of just
the upstream version. At the end there will be a message such as

	Got a build that built! Check in /home/labbott/fedbisect/broken-things/step-0 for rpms

and in that folder there will be RPMs to install (there will also be a number
of logs showing what exactly failed. Those can be ignored).

	$ ls broken-things/step-0/*.rpm
	broken-things/step-0/kernel-9.9.9-0.x86_64.rpm
	broken-things/step-0/kernel-devel-9.9.9-0.x86_64.rpm
	broken-things/step-0/kernel-headers-9.9.9-0.x86_64.rpm

The RPMs are generated from a custom kernel.spec. It's mostly the same as
the regular one but lots of stuff has been ripped out (perf, debug options,
cpu power util etc.) and it's just one big package. This was mostly for ease
of generation of the RPM. When generating snapshots, it turned out to be
a pain to figure out which filters to apply, especially if module names
changed. Copying over parts and editing where necessary seemed like an uphill
battle for not much value. The lifespan of these bisection images is going
to be very short so making the trade off for build ease and time (copying
modules takes a loooong time) seemed reasonable.  In order
to make sure the kernel will always install the version number is 9.9.9-`bisect_step`
so each installation step should be increasing.

Once the kernel is installed, tests can be run. When there is a result,
the build can be marked as good

	$ ./fedbisect.sh good broken-things

or bad

	$ ./fedbisect.sh bad broken-things

or it can be skipped if the build is untestable

	$ ./fedbisect.sh skip broken-things

Now you can build again

	$ ./fedbisect.sh build broken-things

and repeat marking the build as good or bad until the bisect scripts
indicate that a broken commit is found.

These scripts are still in the testing states so there may be problems.
I suspect most of them will be in the setup phase. The scripts are
available on [pagure](https://pagure.io/fedbisect) . Feedback/bug
reports/pull requests are very welcome. Suggestions for future
extensions are also welcome although I have my own list there as well.
