---
layout: post
date: 2016/06/22 11:00:00
title: Caching makes me cranky
category: fedora, complaining
---
Among issues with Ion is its incorrect use of the DMA APIs. I've briefly
[mentioned](http://www.labbott.name/blog/2015/10/22/ion-past-and-future/) this
before. My educated opinion is that it's a complete mess and that time travel
would be a great solution to fix this this problem.

What the DMA APIs do underneath varies greatly depending on what the device is
and what platform you are running on. DMA mapping can range from anything to
setting up device page tables to just returning a physical address. With very
high probability, your cell
phone runs an [ARM](http://www.arm.com/) chip. With very high probability as
well, your laptop is running some kind of x86 chip. The difference I'm going
to highlight here is how the two architectures manage caches. Cache coherency
is a topic worthy of PhD dissertations and many [conference talks](http://events.linuxfoundation.org/sites/events/files/slides/slides_17.pdf) [^1].
The key point for this post is that the ARM architecture does not have the
same cache guarantees as x86 so it needs explicit cache operations when
transfering buffers between devices. The DMA mapping code for [arm](http://lxr.free-electrons.com/source/arch/arm/mm/dma-mapping.c)
and [arm64](http://lxr.free-electrons.com/source/arch/arm64/mm/dma-mapping.c)
includes explicit cache operations as part of mapping and the sync APIs.
Ideally no driver should ever have to think about cache topology and if using
the DMA APIs properly everything happens transparently. DMA APIs work properly
by creating buffer ownership between the CPU and the device. When a driver
calls `dma_map_sg`, the buffer now belongs to the device. The CPU may not
touch the buffer again until `dma_unmap_sg` or
`dma_sync_sg_for_device \ dma_sync_sg_for_cpu` is called. This ensures that
the CPU and the device always see the appropriate data.

Enter Ion. Ion is not a driver for a particular hardware block. It is supposed
to be an allocator for other drivers. Ion was written with Android and its
stack in mind. Too many drivers written for Android do not conform to the
traditional driver model and don't use the DMA APIs. This means drivers have
to manage their caches some other way. Cache operations are easy to get wrong
and can be dangerous to the data of the system. Public APIs are carefully
reviewed and [curated](http://lxr.free-electrons.com/source/Documentation/cachetlb.txt).
The near universal rule in the kernel is that drivers should be relying on the
DMA API (in a correct manner) to do their cache maintenance. The drivers that
don't use the DMA APIs are typically written for one architecture and
[begrudingly](http://lxr.free-electrons.com/source/drivers/irqchip/irq-gic-v3-its.c#L583) call architecture implementations.

Ion, being the central location for all hopes and dreams, became a psuedo-DMA
layer. When a caller allocates memory from Ion, it is guaranteed to be clean
in the cache as if `dma_map` was called. It does this by calling the `dma_sync`
APIs without calling map. This is not allowed by the DMA APIs and just 'happens'
to work for the devices Ion is used on (i.e. cellphones). Why not just call
`dma_map_sg` and let that take care of the caches? Calling map would guarantee
the memory would be synced appropriately with the cache. It would also kill
performance. Buffers in the Android graphics framework are allocated and
deallocated with almost any input. To save on the overhead of allocation, Ion
keeps pages around in a pool that can be drained when under memory pressure.
These pages are guaranteed to be clean in the cache. Calling map each time
on every page would be unnecessary. Even if performance weren't an issue,
what device would be used for mapping? Ion has a device exported to userspace
which could be used. That ends up feeling forced, especially when all that's
needed is the cache operations. Calling map starts the contract of ownership
between device and CPU. The buffer isn't actually being passed off anywhere
so the operations become meaningless. Ion is allocating the buffer for some
other device to eventually map and pass it off.

My attempt to pull caching directly into Ion was [met](http://article.gmane.org/gmane.linux.ports.arm.kernel/502008)
with "No don't do that. Do it properly." I've got a set of APIs that are worth
reviewing but I keep going back and forth on clean up and sending them out.
I'd still like to pull as much of the explicit caching out of Ion as possible
and make those APIs unnecessary. Some of my uncertainty is that I'm not working
on a whole framework. No vendor has a really complete Ion implementation easily
available for me to hack on. I'm making changes a bit blindly in hopes that
others will pick it up. Focusing on one target would give me direction of "Let
the framework support these needs". I could say "Yes, we can stop with the
explicit caching most places and just require drivers call `begin_cpu_access`
or the equivalent userspace calls". Welcome to open source software, I guess.
Anyone can fix anything with the bits and pieces available if they try hard
enough. We'll see where this goes.

[^1]: A big thank you to everyone from ARM for continuing to give these types
of presentations at conferences.
