---
layout: post
date: 2017/01/09 11:00:00
title: That's not what I wanted Linux
category: fedora, complaining
---
Once upon a time, I was an intern at a company doing embedded Linux. This was a
pretty good internship for a student. A lot of my work involved making builds
of open source packages and fixing them when they failed in unusual embedded
environments. One time, I was working in a new environment and halfway through
a build of some package I got what was a cryptic message to me:

	no: command not found

As a beginning developer, I was really confused by this message. It's
saying "no the command isn't found". But what command? I don't remember much of
how I debugged this but I eventually went through the build logs and came across

	checking for perl ...no

The autoconf script was set up incorrectly and set `PERL=no` instead of turning
off perl or erroring out in the config stage. This was fixable by adding perl to
my build environment. Alas, I don't think I fixed the autoconf.

Fast forward to the present day. Someone was reporting a
[build failure](https://lists.fedoraproject.org/archives/list/kernel@lists.fedoraproject.org/thread/5I73T5ZLADXUZ5ZZ3BLYUQNBWHAWRPIL/) 
when rebuilding the rawhide kernel locally. I was seeing the same issue on my
system:

	install: cannot create directory
	'/home/labbott/rpmbuild/BUILDROOT/kernel-4.10.0-0.rc2.git3.2.local.fc26.x86_64/usr/lib64':
	Not a directory

Checking the build tree, `/usr/lib64/` was indeed not a directory. It was a
binary file. Disassembling the binary file showed it was part of perf and seemed
to be related to java. The build logs had this line.

	install libperf-jvmti.so '/home/labbott/rpmbuild/BUILDROOT/kernel-4.10.0-0.rc2.git3.1.fc26.x86_64/usr/lib64'

`install` here behaves in a very \*NIX manner. Without any other options, if
`lib64` exists as a directory, `libperf-jvmti.so` gets copied to the directory.
This is what we expect to happen. If `lib64` does not exist, the .so gets copied
as a file named `lib64`. This is what was happening here. The fix is simple,
check and create the directory exists before running the command. You could even
add a trailing slash to ensure it's actually a directory.

So what is the moral of these stories? <strike>Laura enjoys complaining about Linux</strike>
Your failure modes can produce really non-obvious behaviors if they don't
actually fail. Error checking can be hard and Linux is cold and unfeeling when
you screw up. Bugs will always happen, so review your code carefully.
