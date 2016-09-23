---
date: 2016/09/23 16:00:00
title: kmalloc and vmalloc
tags: fedora
---
The kernel has the responsibility of setting up virtual to physical mappings
for the system. This is something userspace processes take for granted and
don't really think about. Most kernel drivers don't think about this either,
except when it matters. Yes, that's delightfully vague and useless. One of
the most common lines of code you will see in the kernel is an allocation
from kmalloc:

	struct foo *p = kmalloc(sizeof(*p), GFP_KERNEL);

There are assumptions that can be made about a pointer returned from
kmalloc[^1]. The pointer is a virtual address. This sounds obvious but it's
important to keep in mind what that actually means. A pointer returned from
kmalloc is going to be linearly mapped in the page tables. This means the
physical address of a linear virtual address can be found by doing simple
arithmetic. A pointer returned from kmalloc is going to be physically
contiguous. Contrast that with vmalloc:

	void *p = vmalloc(SZ_512K);

The virtual address returned from vmalloc is going to be virtually contiguous
but physically discontiguous. The physical pages that are backing vmalloc
have no relation to the virtual address. Instead of simple arithmetic to
get the physical address, you have to [walk](http://lxr.free-electrons.com/source/mm/vmalloc.c#L235)
the page table to get the physical address for a particular `PAGE_SIZE`.

Both vmalloc and kmalloc have their uses. kmalloc is generally preferred as
the overhead is lower. The linear mapping is set up at boot time and generally
not adjusted. vmalloc is allocated and mapped and mapped at run time. Because
kmalloc is physically contiguous, it's subject to fragmentation. As allocation
size goes up, it may be [necessary](https://marc.info/?l=linux-kernel&m=147455813419596&w=2)
to switch to vmalloc for the allocation to succeed.

Unexpected behavior happens if you pass a vmalloc address to an API that's
not expecting it. Unexpected really means unexpected here. arm64 [will](http://lxr.free-electrons.com/source/arch/arm64/include/asm/memory.h#L190)
[happily](http://lxr.free-electrons.com/source/arch/arm64/include/asm/memory.h#L109)
take a non-linear address and perform a linear translation on it. What you
get back may be a physical address but it has no relation to the virtual
address you passed in. There are some debug options to catch bad uses of
the API and BUG out, but those are expensive and not commonly turned on.

In conclusion, know what type of memory you are allocating and where it
can be used. Don't blindly call `virt_to_phys` on random pointers unless you
like debugging subtle problems.

[^1]: I'm mostly going to be talking about x86 and arm64 with `CONFIG_MMU`
here. Most of this should hold for other architectures but I learn something
new and exciting every day.
