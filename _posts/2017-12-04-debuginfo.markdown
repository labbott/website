---
layout: post
date: 2017/12/04 11:00:00
title: Build ids and the Fedora kernel
category: fedora
permalink: /blog/2017/12/04/build-ids-and-the-fedora-kernel/
---
One of the overlooked aspects of packaging is how much stuff can be handled
automatically for relatively simple packages. Debugging symbols are a good
example. For many packages which support debugging information (compile with
`-g`), the rpm packaging process can automatically separate the debugging
symbols from the binaries with no extra work. The rpm team has put it a lot
of work over the years to make this happen.

The kernel is unfortunately not a simple package. It's had a bunch of custom
macros and functions to handle its debuginfo generation, even as rpm itself
has improved. I did some [work](https://lists.fedoraproject.org/archives/list/kernel@lists.fedoraproject.org/thread/LCXXB6EBVUZRJ4KQ26ZSTNTBDXGAAO72/)
on cleaning up some of this earlier this year with review and feedback from
Mark Wielaard. One of the changes for Fedora 27 was [parallel debuginfo](https://fedoraproject.org/wiki/Changes/ParallelInstallableDebuginfo).
This feature lets you have multiple versions of debugging symbols installed at
once. Given you can have multiple kernel versions installed at once, this is
something that would be valuable to the kernel.

One of the links between a binary and its debugging information is a [Build ID](https://fedoraproject.org/wiki/Releases/FeatureBuildId).
To borrow from the link, "But I'd like to specify it explicitly as being a
unique identifier good only for matching, not any kind of checksum that can be
verified against the contents". By default, passing `--build-id` to the linker
will produce a sha1 sum of parts of the binary that gets put in an ELF note.
You can see this with `readelf -n`:

	Displaying notes found in: .note.gnu.build-id
	  Owner                 Data size	Description
	  GNU                  0x00000014	NT_GNU_BUILD_ID (unique build ID bitstring)
	    Build ID: bbe4ba9f6ebc37ba8764904290077ec7e78ec8a9

Part of the trick with the sha1 sum is that it makes the build id [reproducible](https://reproducible-builds.org/docs/definition/),
building with the same environment will produce the same binaries and therefore
the same build id. Consider the case of a minor version bump to a package with
no change in source code or buildroot. Depending on the package, this may very
well produce the same binary which will have the same sha1 build id. If the
build id is used as part of the file structure of the debuginfo, this may
lead to package conflicts. Part of the work for the
[parallel debuginfo](https://fedoraproject.org/wiki/Changes/ParallelInstallableDebuginfo#Detailed_Description)
was making the build-id unique. As described at the link, part of fixing this
involved 
making changes to [debugedit](https://github.com/rpm-software-management/rpm/blob/master/tools/debugedit.c)
to take the N-V-R as a hash seed. This gets run via [find-debuginfo.sh[^1]](https://github.com/rpm-software-management/rpm/blob/master/scripts/find-debuginfo.sh)
to fixup the build id and other debug paths.

Now enter the kernel. The kernel has the [vDSO](https://en.wikipedia.org/wiki/VDSO)
which gets loaded automatically with each program. The vDSO is encoded in
the [kernel](https://0xax.gitbooks.io/linux-insides/content/SysCall/syscall-3.html)
as a shared object. As a shared object, it also has its own build id. When I
was doing the work earlier in the year, Mark Wielaard gave a quick way to show
this:

	$ eu-unstrip -n -p $$ | grep vdso | cut -d ' ' -f 2
	$ eu-readelf -n /usr/lib/debug/lib/modules/`uname -r`/vdso/vdso64.so.debug | grep "Build ID"

debugedit doesn't know about the vDSO encoded in the kernel but it will happily
update the build id of the vdso.so binary. This ends up breaking the debug
link for the vdso if we make it unique since the debuginfo build id is
different from the in-kernel vDSO build id.

So the end result of this story is that the kernel can't completely handle
parallel debuginfo yet. The build id of the vdso in the kernel must be updated
to be unique and there isn't a good solution for this. The rpm developers are
aware of this problem but all of them are of course busy with other tasks
(they're always very helpful with questions though!). I have some ideas about
how to approach this so ideally if I get some time, I can propose something
for review.

[^1]: The [default invocation](https://github.com/rpm-software-management/rpm/blob/master/macros.in#L177)
of `find-debuginfo.sh` can be found in `macros.in`.
