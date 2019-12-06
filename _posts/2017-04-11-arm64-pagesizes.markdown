---
layout: post
date: 2017/04/11 11:00:00
title: Single images and page sizes
category: fedora
---
"The year of Linux on the desktop" is an old running joke. This has resulted
in many "The year of X on the Y" spin off jokes. One of these that's close to
my heart is "The year of the arm64 server". [ARM](https://www.arm.com/) has
long dominated the embedded space and the next market they intend to capture
is the server space. As [some people](https://twitter.com/jonmasters) will
be more than happy to tell you, moving from the embedded space to the
enterprise class server space has involved some growing pains (and the
occasional meme). Most of the bickering^Wdiscussion comes from the fact that
the embedded world has different requirements than the server world. Trying
to support all requirements in a single tree often means making a
[choice](https://plus.google.com/+JonMasters/posts/GFrXmFUBMuJ) for one
versus the other.

The goal with a distribution like Fedora is to support many devices with as
few images as possible. Producing a separate image means more code to
maintain, more QA, and generally more work. These days we take it for granted
that multiple ARM devices can be booted on the same kernel image. This was
not always the case. Prior to 2012 or so, the platform support that lived
under `arch/arm/` was not designed to work in a unified fashion. Each
vendor had a `mach-foo` directory which contained code that (usually) assumed
only `mach-foo` devices would exist in the image. A good example of this is
header files. Many devices would have header files under
`arch/arm/mach-foo/include/mach/blah.h`. The way the include path was
structured, you could not also compile a device with
`arch/arm/mach-bar/include/mach/blah.h` since there would be two headers with
the same name. Many of the important parts of the platform definition (e.g.
`PHYS_OFFSET`) were `#defines` which meant that platforms with different needs
could not be compiled together.
 Driven by a combination of a
move towards [devicetree](https://lwn.net/Articles/414016/) and the realization
that [none of this was sustainable](https://lwn.net/Articles/501696/), the ARM
community decided to work towards a [single kernel image](https://lwn.net/Articles/513952/). Fast forward to today, and single image booting is standard thanks
to a bunch of hard work.

arm64 learned from the lessons of arm32 and has always mandated a single image.
You can see this reflected in the existence of a single `defconfig` file under
`arch/arm64/configs/defconfig`. This is designed to be a set of options that
are reasonable for most platforms. It is not designed to be a production ready
fully optimized configuration file. This gets brought up occasionally on the
mailing list when people try and submit changes to the `defconfig` file for
optimization purposes.

Fedora is a production system and it does need to be optimized.
There's been fantastic work recently to support more
single board computers like the
[Raspberry Pi](https://fedoramagazine.org/raspberry-pi-support-fedora-25-beta/)
in Fedora. Thanks to single image efforts, the same kernel can boot on both
a Raspberry Pi and an enterprise class ARM server. Booting doesn't mean work
well though. Single Board Computers can come with as little as 512MB of RAM.
Enterprise servers have significantly more.

Consider the choice of `PAGE_SIZE` for Fedora. A page size represents the
smallest amount of physical memory that can be mapped into a
[page table](https://en.wikipedia.org/wiki/Page_table). aarch64 has several
options here, 4K being the most common and 64K giving better [TLB](https://en.wikipedia.org/wiki/Translation_lookaside_buffer)
performance[^1]. A larger page size also means more wasted space. Many
allocations need to be aligned to `PAGE_SIZE` for one reason or another even
if they aren't using close to that amount of space. This can quickly add up to
megabytes of wasted memory. A server with several gigabytes of memory probably 
won't show an impact but a system with 512MB will start to perform poorly due
to lack of RAM. Choosing one page size over the other is going to be
detrimental to one type of machine.

For a more degenerate case of `PAGE_SIZE` problems, we have to look at CMA
(Contiguous Memory Allocator). CMA allows the kernel to get relatively
large (think 8MB or more) physically contiguous allocations. Systems
that use CMA will set up one or more designated CMA regions. The memory in
a CMA region can be used by the system as normal with a few restrictions.
When a driver wants to allocate contiguous memory from a CMA region, the
kernel will use underlying page migration/compaction[^2] to allocate
the block of memory. To help ensure the migration can succeed, CMA regions
have a minimum size. When `PAGE_SIZE` is larger, the minimum size goes up
as well. The particular combination of options Fedora uses makes the minimum
size go up to 512MB when a larger `PAGE_SIZE` is used on arm64. Given other
requirements for CMA, this essentially means CMA can't be used on smaller
memory systems if a larger page size is used since the alignment requirements
are too strict. And thus we get people making [choices](https://plus.google.com/+JonMasters/posts/GFrXmFUBMuJ) 
about what gets supported.

One way to avoid the need to make multi-platform trade offs is to make more
options runtime selectable. This is popular with many debug features that
can be builtin with the appropriate `CONFIG_FOO` option but are only actually
run when an argument is passed on the kernel command line. This doesn't
work for anything that needs to be determined at compile time though.
`PAGE_SIZE` almost certainly falls into this category as do many other
constants in the kernel. The end result is that you will never be able to
find one true build configuration that's optimal for all situations.
The best you can hope to do is foist the problem off on someone else and
let them make the trade offs so you don't have to. Or evaluate what your
requirements actually are and go from there. Either works.

[^1]: If you don't believe page size will actually make a difference, try
talking to a hardware engineer and asking for some graphs. Better yet, ask
them for some hardware optimized for a larger page size and then use a smaller
page size.

[^2]: [LWN](http://www.lwn.net) has some older articles about the technologies
for the interested. I should also write more about CMA some time.
