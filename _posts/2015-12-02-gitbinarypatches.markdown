---
layout: post
date: 2015/12/02 16:00:00
title: Git, binary files, and patches
category: fedora, kernel
---
	$ mkdir test_repo
	$ cd test_repo/
	$ git init
	Initialized empty Git repository in /home/labbott/test_repo/.git/
	$ touch foo
	$ git add foo
	$ git commit -m "this file"
	[	master (root-commit) c51ba67] this file
	1 file changed, 0 insertions(+), 0 deletions(-)
	create mode 100644 foo
	$ cp ~/a.out .
	$ file a.out
	a.out: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter
	/lib64/ld-linux-x86-64.so.2, for GNU/Linux 2.6.32,
	BuildID[sha1]=96d6131eb203b850d42b53a7f5ebc512056ec739, not stripped
	$ git add a.out
	$ git commit -m "A binary file"
	[master d5bdd17] A binary file
	1 file changed, 0 insertions(+), 0 deletions(-)
	create mode 100755 a.out
	$ git rm a.out
	rm 'a.out'
	$ git commit -m "no binary"
	[master 9dd9f2b] no binary
	1 file changed, 0 insertions(+), 0 deletions(-)
	delete mode 100755 a.out
	$ git format-patch -1 --no-binary HEAD
	0001-no-binary.patch
	$ git reset --hard HEAD^
	HEAD is now at d5bdd17 A binary file
	$ patch -p1 < 0001-no-binary.patch
	patching file a.out
	Not deleting file a.out as content differs from patch
	$ echo $?
	1
	$ cat 0001-no-binary.patch
	From 9dd9f2b6c717d4125d790610941f258bdb573ee4 Mon Sep 17 00:00:00 2001
	From: Laura Abbott <labbott@fedoraproject.org>
	Date: Wed, 2 Dec 2015 10:45:33 -0800
	Subject: [PATCH] no binary

	---
	a.out | Bin 8784 -> 0 bytes
	1 file changed, 0 insertions(+), 0 deletions(-)
	delete mode 100755 a.out

	diff --git a/a.out b/a.out
	deleted file mode 100755
	index 3772793..0000000
	Binary files a/a.out and /dev/null differ
	-- 
	2.5.0
	$

This is the story behind
[a recent bugzilla](https://bugzilla.redhat.com/show_bug.cgi?id=1284720).
The patches generated on kernel.org only say that the binary files changed
so they can't actually be applied as diffs.
Git deals with binary files just fine though so it's possible to sneak
some in and end up with a tree that can't be easily expressed in patches.
Binary files usually don't have a place in the kernel, but some
did come in with a staging driver. The staging driver was
[deleted](https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=6512edec48b2ccfe9bb969ce26ebbbcd49de6c4b)
this merge window. Everything that isn't an official x.y kernel release (e.g.
4.3-rc4, 4.2.3) comes in as a patch file so all patches are going to be
unappliable until that commit makes it into an official release. The workaround
right now is to modify the patch to get rid of the binary file deletion. This
does mean the checksums aren't going to match against kernel.org but this is
only going to be the case until the next official release in rawhide which
should be sometime at the beginning of January. You'll just have to
trust the Fedora kernel team in the mean time.
