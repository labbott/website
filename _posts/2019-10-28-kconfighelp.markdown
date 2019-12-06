---
layout: post
date: 2019/10/28 11:00:00
title: Why you can't (easily) get Kconfig help from the command line
category: fedora
---
When something seemingly simple isn't implemented in an open source project,
there are two likely reasons. One, nobody has bothered to sit down and work
on it because it's so simple. Two, it's not actually as simple as it may seem.
Getting Kconfig help text really felt like it should be that simple but,
alas, was not.

When I see a config option I don't understand, my usual methods for finding
out more information are either to invoke `make menuconfig` and search there
or running `git grep "config FOO"` to find the file. Both of these work but
are manual and not really suitable for automation. What I wanted was a
single command to run and spit out only the help text on the command line.

All the kconfig work lives in `scripts/kconfig`. Roughly speaking, each
of the ways to invoke config (menuconfig, xconfig, etc.) uses a common set
of parsing code and then a different set of methods to display/use the kconfig
information in whatever way. How to handle input is handled by the specfic
instance of kconfig invocation. Theoretically, it means it would be easy
to add another target to parse the kconfig and get the help text that way,
e.g.

	@@ -158,6 +162,11 @@ conf-objs  := conf.o $(common-objs)
	 hostprogs-y    += nconf
	 nconf-objs     := nconf.o nconf.gui.o $(common-objs)
	
	+# helpconf: get the dang help menu
	+hostprogs-y    += helpconf
	+helpconf-objs  := help.o $(common-objs)
	+
	 HOSTLDLIBS_nconf       = $(shell . $(obj)/nconf-cfg && echo $$libs)
	 HOSTCFLAGS_nconf.o     = $(shell . $(obj)/nconf-cfg && echo $$cflags)
	 HOSTCFLAGS_nconf.gui.o = $(shell . $(obj)/nconf-cfg && echo $$cflags)


The trick here is that all the kconfig work gets invoked via make (e.g.
`make menuconfig`, `make defconfig`). It turns out, if you try and invoke
any of the kconfig programs without make, things blow up:

	$ make V=1 listnewconfig
	make -f ./scripts/Makefile.build obj=scripts/basic
	rm -f .tmp_quiet_recordmcount
	make -f ./scripts/Makefile.build obj=scripts/kconfig listnewconfig
	scripts/kconfig/conf  --listnewconfig Kconfig
	$ scripts/kconfig/conf  --listnewconfig Kconfig
	sh: /scripts/gcc-version.sh: No such file or directory
	sh: /scripts/gcc-version.sh: No such file or directory
	init/Kconfig:18: syntax error
	init/Kconfig:17: invalid statement
	init/Kconfig:18: invalid statement
	sh: /scripts/clang-version.sh: No such file or directory
	init/Kconfig:26: syntax error
	init/Kconfig:25: invalid statement
	Recursive inclusion detected.
	Inclusion path:
	current file : arch//Kconfig
	included from: arch//Kconfig:10

this is because Kconfig expects certain make variables to be defined:

	$ srctree=`pwd` CC=gcc ARCH=x86 SRCARCH=x86 scripts/kconfig/conf --listnewconfig Kconfig
	$

So unless we (really) want to be reinventing the wheel, we're stuck invoking
all kconfig programs via make.

This doesn't sound terrible but if we think about what a reasonable
command might be (e.g. `make helpconfig CONFIG_FOO`), this means we need to
parse arguments passed to make itself, which is is not something make is
easily designed to handle. Yes, you can do so but it really isn't pretty.
One suggested workaround is to have the option
as an environment variable (e.g. `make OPTION=CONFIG_FOO helpconfig`) but
that ends up feeling pretty ugly and prone to namespace collisions.

The end result is that adding the feature by itself ends up causing more
problems than it actually solves. I do have an actual use case for getting
help text from the command line but my proposed solution for that will
almost certainly look different than this idea.
