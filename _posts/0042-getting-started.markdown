---
date: 2016/08/15 11:00:00
title: Ideas for getting started in the Linux kernel
categories: fedora
---
Getting new people into OSS projects is always a challenge. The Linux kernel
is no different and has it's own set of challenges.  This is a follow up and
expansion of some of what I talked about at [Flock](http://www.labbott.name/blog/2016/08/08/flock-2016/)
about contributing to the kernel.

When I tell people I do kernel work I tend to get a lot of "Wow that's really
hard, you must be smart" and "I always wanted to contribute to the kernel but
I don't know how to get started". The former thought process tends to lead
to the latter, moreso than other projects. I would like to dispel this notion
once and for all: you do not have to have a special talent to work on the
kernel unless you count dogged persistence and patience as a talent. Working
in low level C has its own quriks the same way working in other languages does.
C++ templates terrify me, javascript's type system (or lack there of) confuses
me. You can learn the skills necessary to work in the kernel.

The answer to the question "So how do I get started in the kernel?" really
varies and depends on your motivation. Are you interested in knowing how
operating systems work in general? Do you want to know how parts of Linux
specifically work? Is your hardware broken? Is some part of Linux ruining your
day? Do you just want to make an Open Source contribution? Do you want a high
five [^1]? Different tasks are going to be better suited for different
motivations.

The classic way first timers get started with the kernel is by fixing
checkpatch errors in staging. [Kernel Newbies](https://kernelnewbies.org/FirstKernelPatch)
has a great introduction to get started[^2]. This task hits some important
milestones: it ensures you can grab a copy of the kernel, build it
successfully, make a patch with git, send it out and respond to feedback. If
you are just looking for a quick open source contribution, checkpatch fixes
in staging are great. The task starts to lose its value the more you do it
though. There are a large number of people fixing up checkpatch issues so
getting them fixed up is very easy. Fixing up checkpatch issues outside the
staging directory tends to have mixed results, some maintainers will accept
them others will ignore them. checkpatch is just a perl script so it can
generate false positives. Always remember to compile test and boot if
possible.

Figuring out what to do after/instead of checkpatch issues is a mostly open
problem. There is no one right path to take. I gave this some thought and
came up with a list that might be helpful. Note many of these aren't immediate
patches or things you can do but more 'meta tasks' that may help you figure
out other contributions you can make. I make no guarantee anything here will
actually turn you into a kernel developer (but if it does I'd love to know!)
Please also use your best judgment when sending patches and think about what
you are doing:

- If you don't have much of an operating systems background, read up on some
of the [fundamentals](http://wiki.osdev.org/Main_Page). This will give you
a much better idea about the types of errors and crashes you can run into.

- There are some [books](http://free-electrons.com/doc/books/ldd3.pdf) out
out there about kernel development. Many of the details are now out of date
but high level concepts can be useful.

- Run on 'unusual' hardware. Debug your unusual hardware.

- The [Eudyptula Challenge](http://eudyptula-challenge.org/) is a more
structured introduction to the kernel. It's a set of small challenges.

- Checkers like [Coccinelle](http://coccinelle.lip6.fr/) and [smatch](http://smatch.sourceforge.net/)
are a nice step up from checkpatch. These tools require a bit more thought.
Like checkpatch, please use your judgment and always make sure the code
compiles. If making a tree wide change, please only submit a few (5 at most)
as a sample. Make sure to give patches appropriate subjects and Cc the
appropriate maintainers.

- Learn to read a kernel oops and warning. Learn how to use addr2line to match
up addresses with code. Learn how to run [decodecode](http://lxr.free-electrons.com/source/scripts/decodecode)

- Learn what some of the more common warnings (e.g. sleeping while atomic) mean
and what are common ways they can be fixed.

- Learn how to read a lockdep [report](http://people.redhat.com/srostedt/lockdep-plumbers-2011.odp).

- Run [linux-next](http://lxr.free-electrons.com/source/Documentation/HOWTO#L315).
Report problems you find (after searching the mailing list to see if they have
been reported already of course)

- Find a patch set on the mailing list, figure out how to test it and report
back. Ideally this would be about a subsystem you are interested in learning
more about and something with an existing set of test cases.

- Test something on a non-x86 architecture. The kernel has gotten significantly
better in recent years about being less x86-centric but most developers still
run on x86. It's [easy](http://www.labbott.name/blog/2016/04/22/quick-kernel-hacking-with-qemu-+-buildroot/)
to build on QEMU for arm and arm64 if you don't have hardware.

- Learn about PCI ids and how they match up to hardware. More generically,
learn about quirks for various subsystems. What does a subsystem use to
determine if a quirk should be applied?

- New [format](http://lxr.free-electrons.com/source/Documentation/printk-formats.txt)
options for print strings have been added (e.g. %pa for physical
addresses). Some drivers are still using non-portable casts and could be
converted.

- Read the documentation. Read the corresponding code. If there is a mismatch,
try submitting a patch to the documentation.

- Learn how to run [ftrace](http://lxr.free-electrons.com/source/Documentation/trace/ftrace.txt) and [perf](https://perf.wiki.kernel.org/index.php/Main_Page).
These are valuable debugging tools.

- Run [kmemleak](http://lxr.free-electrons.com/source/Documentation/kmemleak.txt),
[kasan](http://lxr.free-electrons.com/source/Documentation/kasan.txt)
and other debugging features. Report bugs _after_
searching the mailing list to see if anyone has reported it as a false positive.

- Security is fun! Learn how to write a simple kernel exploit. Read CVEs,
learn why they are considered security bugs. [Android](https://source.android.com/security/overview/updates-resources.html)
is a great source of kernel bugs to learn from.

- Learn how to do a bisection. When you inevitably hit a problem, provide a
bisect log along with your report.

- Read your dmesg logs. Investigate interesting messages.

- Take a USB drive, insert it into your computer. Trace how it gets
enumerated. Learn how the [bad usb](http://events.linuxfoundation.org/sites/events/files/slides/understand_usb_in_linux_krzysztof_opasiak.pdf) attack works.

- Learn how to capture [usbmon](http://lxr.free-electrons.com/source/Documentation/usb/usbmon.txt)
output. Trace the USB protocol.

- Take a syscall (open, mmap), put in arguments that give an error code.
Trace the syscall to identify the line which is generating the error code.
Look at the checks which are generating this error.

- Figure out how your firmware (BIOS/EFI/Devicetree whatever) specifies which
regions of memory the kernel can use. Trace how those regions get set up in the
early memblock allocator and later the buddy allocator.

- Draw a picture of how the buddy allocator works. Give all the memory blocks
happy faces when they get merged together with a buddy. (I have wanted to do
this for years).

- Draw a picture of how the SLUB allocator works. How does it change when
SLUB_DEBUG options are used?

- Write a [BPF](http://lxr.free-electrons.com/source/Documentation/networking/filter.txt) filter

- Trace how you [walk the page tables](http://lxr.free-electrons.com/source/arch/x86/mm/dump_pagetables.c).
How does this compare with functions that [modify the page tables](http://lxr.free-electrons.com/source/kernel/module.c#L1855)?



[^1]: If that's your motivation I will give you a high five the next time I
see you at a conference.

[^2]:  I recommend this tutorial to everyone for getting their git environment
setup regardless of if you want to send checkpatch clean ups.

