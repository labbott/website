---
layout: post
date: 2018/07/10 11:00:00
title: The cabbage patch for linker scripts
category: fedora
permalink: /blog/2018/07/10/the-cabbage-patch-for-linker-scripts/
---
Quick quiz: what package provides `ld`? If you said binutils and not gcc, you
are a winner! That's not actually the story, I just tend to forget which package
to look at when digging into problems. This is actually a story about binutils,
linker scripts, and toolchains.

Usually by -rc4, the kernel is fairly stable so I was a bit surprised when
the kernel was failing on arm64:

	ld: cannot open linker script file ldscripts/aarch64elf.xr: No such file or directory

There weren't many changes to arm64 so it was pretty easy to narrow down the
problem to a seemingly [harmless](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/arch/arm64?id=38fc4248677552ce35efc09902fdcb06b61d7ef9)
change. If you are running a toolchain on a standard system such as Fedora, you
will probably expect it to "just work". And it should if everything goes to
plan! binutils is a very powerful library though and can be configured to allow
for emulating a bunch of less standard linkers, if you run `ld -V` you
can see what's available:

	$ ld -V
	GNU ld version 2.29.1-23.fc28
	  Supported emulations:
	   aarch64linux
	   aarch64elf
	   aarch64elf32
	   aarch64elf32b
	   aarch64elfb
	   armelf
	   armelfb
	   aarch64linuxb
	   aarch64linux32
	   aarch64linux32b
	   armelfb_linux_eabi
	   armelf_linux_eabi
	   i386pep
	   i386pe


This is what's on my Fedora system. Depending on how your toolchain is
compiled, the output may be different. A common variant toolchain setup is the
'bare metal' toolchain. This is (generally) a toolchain that's designed to
compile binaries to run right on the hardware without an OS. The kernel
technically meets this definition and provides all its own linker
scripts so in theory you should be able to compile the kernel with a properly
configured bare metal toolchain. What the [harmless](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/arch/arm64?id=38fc4248677552ce35efc09902fdcb06b61d7ef9)
looking change did was switch the emulation mode from linux to one that works
with bare metal toolchains.

So why wasn't it working? Looking across the system, I found no trace of
the file `aarch64elf.xr`, yet clearly it was expecting it. Because this seemed
to be something internal to the toolchain, I decided to try another one.
Linaro helpfully provides [toolchains](https://releases.linaro.org/components/toolchain/binaries/)
for compiling arm targets. Turns out the Linaro toolchain worked. `strace`
helpfully showed where it was picking up the file[^1]:

	lstat("/opt/gcc-linaro-7.1.1-2017.08-x86_64_aarch64-linux-gnu/aarch64-linux-gnu/lib/ldscripts/aarch64elf.xr", {st_mode=S_IFREG|0644, st_size=5299, ...}) = 0

So clearly the file was supposed to be included. Looking at the build log
for Fedora's binutils, I could definitely see the scripts being installed. Further
down the build log, there was also a nice `rm -rf` removing the directory
where these scripts were installed to. This very deliberately [exists](https://src.fedoraproject.org/rpms/binutils/blob/master/f/binutils.spec#_568)
in the spec file for building binutils with a comment about gcc. The history
doesn't make it completely clear, but I suspect this was either intended to
avoid conflicts with something gcc generated or it was 'borrowed' from gcc
to remove files Fedora didn't care about. Linaro, on the other hand, chose
to package the files with their toolchain. Given Linaro has a strong embedded
background, it would make sense for them to care about emulation modes that
might be used on more traditional embedded hardware.

For one last piece of the puzzle, if all the linker scripts are `rm -rf'd`
why does the linker work at all, shouldn't it complain? The binutils source
has the answer. If you trace through the source tree, you can find a [folder](https://sourceware.org/git/gitweb.cgi?p=binutils-gdb.git;a=tree;f=ld/emulparams;h=9123d367fd4490d5e69e0b5d45701fcb975931b0;hb=HEAD)
with all the emulation options, along with the template they use for generating
the structure representation. There's a nice check for `$COMPILE_IN` to
actually build a linker script into the binary. The file [genscripts.sh](https://sourceware.org/git/gitweb.cgi?p=binutils-gdb.git;a=blob;f=ld/genscripts.sh;h=370b22269db2ee9962153bcd19ef1edcf8724127;hb=HEAD#l472)
is actually responsible for generating all the linker scripts and will
compile in the default script. This makes sense, since you want the default
case to be fast and not hit the file system.

I ended up submitting a revert of the patch since this was a regression, but
it turns out Debian suffers from a similar problem. The real take away here
is toolchains are tricky. Choose yours carefully.

[^1]: You also know a file is a bit archaic when it has a comment about the
Solaris linker
