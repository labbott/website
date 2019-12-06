---
layout: post
date: 2016/11/29 11:00:00
title: virt to phys and back again
category: fedora
---
I've been working on `CONFIG_DEBUG_VIRTUAL` support for arm64. This is designed
to catch bad uses of `virt_to_phys`[^1] on non-linear
addresses. Translating between virtual and physical addresses is very
architecture specific. The kernel expects each [architecture](https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/io.h)
to [define](https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/arch/arm64/include/asm/memory.h)
these appropriately. At the simplest level, supporting a debug check is a
matter of adding the appropriate `#ifdef` and calling a new function.
Architectures are rarely that simple though.

I've talked before about [kmalloc and vmalloc](http://www.labbott.name/blog/2016/09/23/kmalloc-and-vmalloc/).
kmalloc memory is linearly mapped (can call `virt_to_phys`) whereas vmalloc
memory is not. The kernel image (everything built into a vmlinux for the
purposes of this discussion) is yet another[^2] range of memory. This is
mapped linearly but may not be the same as kmalloc memory. On arm64, the kernel
image can be placed anywhere in physical memory. Virtually, the kernel image
is placed at the end of module space/start of vmalloc space. The `virt_to_phys`
translation currently covers both of these ranges:

	#define __virt_to_phys(x) ({                                           \
		phys_addr_t __x = (phys_addr_t)(x);                            \
		__x & BIT(VA_BITS - 1) ? (__x & ~PAGE_OFFSET) + PHYS_OFFSET :  \
			                 (__x - kimage_voffset); })

The choice of layout means that bit `VA_BITS - 1` in the virtual address space
can be used to distinguish between 'regular' linear addresses and kernel image
virtual addresses.

Enforcing the debugging ranges gets much easier if this can be broken up into
two different parts, one for the standard linear range and one for the kernel
image. Fortunately, the kernel already has a macro `__pa_symbol` for symbols
so it's easy to define and use that. Part of the work for implementing
`CONFIG_DEBUG_VIRTUAL` now becomes converting calls of
`__pa(some_kernel_symbol)` to `__pa_symbol(some_kernel_symbol)`. This
gets more difficult when the `__pa` call is embedded in another function. A
good example of this is the [`p*d_populate`](https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/arch/arm64/include/asm/pgalloc.h) 
functions. These setup page tables and call `__pa` but need to work with both
kernel symbols and regular linear memory. So what to do?

The `phys_to_virt` function is defined like so

	#define __phys_to_virt(x)       ((unsigned long)((x) - PHYS_OFFSET) | PAGE_OFFSET)

Notice how this is the reverse of the kernel linear map in `__virt_to_phys`.
The kernel image is actually an alias of part of the regular linear address.
Alias here means that two different virtual addresses map to the same physical
address. The easiest way to work with functions that need to call `__pa` is
to translate kernel symbol addresses to their linear aliases. Since `__va`
will always return an address in the linear range, we can pass the physical
address of a kernel image symbol and translate it back:

	#define lm_alias(x)		__va(__pa_symbol(x))

This essentially does a virt -> phys -> virt translation but the starting and
ending virtual addresses are not the same.
The linear alias of the kernel image can be passed to functions that use `__pa`
without a problem. There's still some limitations on the alias. `__va` uses
`PHYS_OFFSET`

	/* PHYS_OFFSET - the physical address of the start of memory. */
	#define PHYS_OFFSET             ({ VM_BUG_ON(memstart_addr & 1); memstart_addr; })

There's a nice `VM_BUG_ON` to bring down the system if `PHYS_OFFSET` is used
too early. This means that the alias trick can't be used until after a certain
point in bootup. Before that, `__pa_symbol` is the only option to get physical
addresses of kernel symbols.

The `CONFIG_DEBUG_VIRTUAL` patches for arm64 are still under review but most
of the major issues have been worked out. Hopefully they will be merged soon.

[^1]: For purposes of this discussion, `virt_to_phys` includes several
functions that while not identical are similar enough to assume they do the
same thing. `__pa` and `__virt_to_phys` are included in this category.

[^2]: If your distro supports it, try running `cat
/sys/kernel/debug/kernel_page_tables` to see the entire virtual address space.

