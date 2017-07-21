---
date: 2017/07/21 11:00:00
title: Fun with stacks
categories: fedora
---
Like much of the kernel, most people don't think about the kernel stack until
something goes wrong. Several topics have come up recently related to
kernel stacks.

Back in June, a critical bug called [stack clash](https://blog.qualys.com/securitylabs/2017/06/19/the-stack-clash)
was publicly disclosed by a security research firm. For purposes of this
discussion, the runtime heap typically starts at low addresses and grows up.
The stack starts at high addresses and grows down (shouting "the stack grows
down" is a time honored tradition when working with the stack). The heap is
typically managed by some memory manager (usually your libc malloc) with
explicit calls to `brk` to increase the heap size. The program stack grows
automatically as it is used. The logic for determining if an access is part of
the automatic stack or a bogus access is approximately "if it's close enough
to the bottom of the existing stack, it's probably fine. Trust me." As you
might expect, things go poorly if the stack grows next to the heap memory and
starts using that as a stack. Several years ago, the kernel added a guard
page to help mitigate this problem. Instead of immediately growing into the
heap right below the stack, the program would access an unmapped page and
then fault. "page" here refers to a region of memory that is literally a
`PAGE_SIZE`, typically 4K. The stack clash researchers discovered several
vulnerabilities in userspace programs that allowed a jump of larger than a
`PAGE_SIZE`, thus defeating the guard page.

The biggest issue with this vulnerability is that it's essentially a design
limitation. There's nothing guaranteeing any behavior to completely mitigate
the problem. Userspace can allocate as much junk on the stack as it wants
and call `alloca` to its heart content until it runs out of space. The kernel
added a [work around](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=1be7107fbe18eed3e319a6c3e83c78254b693acb)
to increase the gap between the stack and VMAs. The commit text freely admits
this isn't a full fix since it only decreases the chance of some userspace
program managing to grow the stack pointer into another region. The gcc
developers have a [proposal](https://gcc.gnu.org/ml/gcc-patches/2017-07/msg00557.html)
for an actual mitigation by probing the stack at regular intervals to make sure
the guard page gets hit. This does require recompiling programs with the
appropriate flag so the kernel work around is still important to have.

In the [self-protection](https://kernsec.org/wiki/index.php/Kernel_Self_Protection_Project)
area, Alexander Popov posted a port of the stackleak plugin from
Grsecurity/PaX. Information leaks from the kernel to userspace can be combined
with other bugs to give full kernel exploits. A common source of information
leaks is [copying](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=e4ec8cc8039a7063e24204299b462bd1383184a5)
[uninitialized](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=9a47e9cff994f37f7f0dbd9ae23740d0f64f9fe6)
stack data to userspace. The stackleak plugin aims to mitigate this by clearing
the stack after each system call, reducing the chance of kernel data getting
leaked to userspace. The plugin part of the stackleak plugin is a gcc plugin
to call `track_stack` on functions with a stackframe over a certain size.
`track_stack` updates the lowest value of the stack pointer. When a system
call finishes, the area between the top of the stack and the lowest stack
pointer is cleared. The Grsecurity/PaX version only included support for x86.
I made a first pass attempt at a version for arm64. Apart from being useful
for full architecture support, this was a helpful exercise to figure out what
assumptions the existing code was making. Hopefully feedback will continue
to come in so the series can make progress towards merging.
