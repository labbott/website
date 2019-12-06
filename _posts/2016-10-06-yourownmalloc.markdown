---
layout: post
date: 2016/10/06 11:00:00
title: Write your own kmalloc
category: fedora
---
While at Linaro connect, I was discussing with someone the state of the
[Energy Aware Scheduler (EAS)](http://www.linaro.org/blog/core-dump/energy-aware-scheduling-eas-project/)
patches. This is an ongoing project to update the Linux kernel scheduler to
be aware of processor hardware to make better scheduling decisions and reduce
power usage. Parts of the patch set have been accepted upstream but a large
part still exists out of tree. The patch set is fairly intrusive and the
scheduler in the kernel is a finicky piece of code. The EAS patches take a good
bit work to maintain which brought up a general discussion of what subsystems
would be easier or harder to replace than the scheduler. Someone proposed that
kmalloc would be difficult but thinking about it, kmalloc is one of the easier
places to write a new implementation.

kmalloc in the kernel serves the same purpose as malloc in userspace; it
allocates heap memory. The fundamental behavior works the same as in userspace
too:

	malloc(something)
		try to allocate some memory
		if (I found some memory)
			return what I found
		else
			increase my heap
			if (I can't increase my heap)
				uh oh out of memory :(
			try to allocate some memory
			if (I found some memory)
				return what I found
			else
				uh oh out of memory :(

Yes, this is very hand wavy. The point here is that the heap is dynamic, it
grows with the size of the program. In userspace, the size of the heap is
controlled by [sbrk](https://en.wikipedia.org/wiki/Sbrk) or a similar system
call. In the kernel, kmalloc makes calls to the underlying page allocator
(`alloc_page`). This is a part of the kernel that many people get confused
about, what's the difference between a call to `kmalloc` and a call to
`alloc_pages`? `alloc_pages` is the lowest level memory allocator using
[buddy allocation](https://en.wikipedia.org/wiki/Buddy_memory_allocation)
to allocate pages in `PAGE_SIZE` order. A typical page size is 4096 bytes.
Most allocations do not require 4096 bytes. kmalloc sits on top of the
buddy allocator to manage smaller allocation sizes. In general, the buddy
allocator is only used directly when a physically contiguous `PAGE_SIZE`
allocation is needed. `kmalloc` should be used unless there is a specific
use case in mind.

The slab allocator works on top of `alloc_pages`. The kernel currently offers
three different algorithms, SLOB, SLAB, and SLUB. There was a very good
[talk](http://events.linuxfoundation.org/sites/events/files/slides/slaballocators.pdf)
a few years ago about the differences between these allocators. In general,
SLOB is old and isn't used except in select circumstances, SLAB was the
replacement followed by SLUB. Most of the work these days is done on SLUB.
The different allocators are kept around because some people care about the
use cases where one performs better than another. Because of this, the code
is written to make it easy to add a drop in replacement.

I decided to see just how self-contained a new allocator would be.

- I started by defining a new Kconfig item in `init/Kconfig` to select a new
algorithm type.

- Defines for `KMALLOC_MIN_SIZE`, `KMALLOC_SHIFT_LOW`, `KMALLOC_SHIFT_HIGH`
were needed. I borrowed the definitions from SLAB for the purposes of compiling.

- `struct kmem_cache` had to be defined in `mm/slab.h`[^1] I ended up just
using the same definition as `CONFIG_SLOB` plus a node field for some
`#ifndef CONFIG_SLOB`

- At this point, the kernel would compile but fail to link. I added stub
functions for `kfree`, `__kmalloc`, `kmem_cache_alloc`, `kmem_cache_free`,
`__kmalloc_node`, `kmem_cache_alloc_trace`, `kmem_cache_alloc_node_trace`,
`kmem_cache_alloc_node`, `kmem_cache_free_bulk`, `kmem_cache_alloc_bulk`,
`ksize`, `__kmalloc_node_track_caller`, `__kmalloc_track_caller`,
`kmem_cache_init`, `kmem_cache_init_late`, `__kmem_cache_shutdown`,
`__kmem_cache_release`, `__kmem_cache_shrink`, `__kmem_cache_alias`,
`__kmem_cache_create`, `kmem_cache_flags`, a total of 21 functions.

And that was enough to get the kernel to compile. Obviously this kernel won't
boot since the stub malloc always returns `NULL`.

Compared to replacing other fundamental parts of the kernel, this was very
easy. The code changes needed outside a file that contained a new
implementation (or in my case stubs) were fairly small. Does this mean everyone
should go out and write a brand new allocator for submission to the community?
Almost certainly not. Most work upstream should be on expanding existing
allocators. A new allocator would need piles of benchmarking and research to
be considered for acceptance, and it would have to be better than what's there.
It's much better to have one allocator that works for as many cases
as possible versus a new allocator for every use case. That doesn't mean
research shouldn't happen on your own. Writing your own memory allocator is an
excellent project for learning that doesn't need to be submitted to the
community. If you've never written an allocator before
(in user or kernel space) I highly recommend it. Forking off one of the
existing allocators and making changes on top can be a great way to compare
against a known baseline. Once your changes are validated, they can be
submitted to the existing allocator.

In conclusion, kmalloc in the kernel is self contained, so [break your kernel](http://www.labbott.name/blog/2015/12/14/it-s-okay-break-your-kernel/)
by experimenting with it. You might get some ideas that can be turned into a
project for existing allocators.

[^1]: Confusingly, `slab` is used to refer to all the types of allocators in
many places such as `include/linux/slab.h`, `slab_common.c` and not just the
`CONFIG_SLAB` allocator.
