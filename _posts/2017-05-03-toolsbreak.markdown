---
layout: post
date: 2017/05/03 11:00:00
title: When tools break the kernel
category: fedora
---
The kernel is really self-contained. This makes it great for [trying](http://www.labbott.name/blog/2015/12/14/it-s-okay-break-your-kernel/)
experiments and breaking things. It also means that most bugs are also going to
be self-contained. I say most because the kernel still has dependencies on
other core system packages and when those change, the kernel can break as well.

All the low level packages on your system are usually so well maintained you
don't even realize they are present[^1].
[binutils](https://www.gnu.org/software/binutils/) provides tools for working
with binary files. The [assembler](https://sourceware.org/ml/binutils/2015-05/msg00133.html)
will get updates for features such as instruction set updates.
Changes like these can [break](https://bugzilla.redhat.com/show_bug.cgi?id=1267395)
the kernel unexpectedly though. [glibc](https://www.gnu.org/software/libc/)
is another [popular](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=b2e1c26f0b62531636509fbcb6dab65617ed8331)
package for updates which break the kernel. The word 'break' here does not mean
the changes from glibc/binutils were incorrect. The kernel makes a lot of
assumptions about what's provided by external packages and things are bound
to get out of sync occasionally. This is a big part of the purpose of rawhide:
to find dependency problems and get them fixed as soon as possible.

Updates to the compiler can be more ambiguous about whether or not a change
is a regression. Compiler optimizations are designed to improve code but
may also change the behavior in unexpected ways. A good example of this is
some recent optimizations related to constants. For those who haven't studied
compilers, constant folding involves identifying expressions that can be
evaluated to a constant at compile time. gcc provides a [builtin function](https://gcc.gnu.org/onlinedocs/gcc/Other-Builtins.html)
`__builtin_constant_p` to let code behave differently depending on if an
expression can be evaluated to a constant at compile time. This sounds fairly
simple for cases such as `__builtin_constant_p(0x1234)` but it turns out to
be more [complex](https://gcc.gnu.org/bugzilla/show_bug.cgi?id=72785) for
actual [code](http://lists.infradead.org/pipermail/linux-arm-kernel/2016-October/461597.html)
when combined with more complex compiler analysis. The end result is that a
new compiler optimization broke some assumptions about how the kernel was using
`__builtin_constant_p`. One of the risks of using compiler builtin functions
is that the behavior is defined but only to some degree. Developers may argue
that a compiler is doing something incorrect but it turns out to be easier
just to [fix](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=474c90156c8dcc2fa815e6716cc9394d7930cb9c)
the kernel.

Sometimes the compiler is just plain wrong. New optimizations may eliminate
[critical](https://bugzilla.redhat.com/show_bug.cgi?id=1447166) portions
of code. Identifying such bugs is a special level of debugging. Typically,
you end up staring at the code wondering how it could end up in such a
situation. Then you get an idea that staring at assembly will somehow
be less painful at which point you notice that a critical code block is
missing. This may be followed by yelling.
For kernel builds, comparing what gets pulled into the buildroot
of working and non-working builds can be a nice hint that something outside
the kernel has gone awry.

As a kernel developer, I am appreciative to the fantastic maintainers of the
packages the kernel depends on. All the times I've reported issues in Fedora
the maintainers have been patient and helpful in helping me figure out how
to get the right debugging information to determine whether an issue is in
gcc/binutils/glibc or the kernel. The kernel may be self-contained but it
still needs other packages to work.

[^1]: Until your remove them with the --force option, then you really miss them.
