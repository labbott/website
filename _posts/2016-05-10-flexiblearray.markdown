---
layout: post
date: 2016/05/10 16:00:00
title: Zero size arrays in C
category: fedora
---
The current structure definition of the ion system heap involves a zero sized
array:

	struct ion_system_heap {
		struct ion_heap heap;
		struct ion_page_pool *pools[0];
	};

It looks odd but [it's valid](https://gcc.gnu.org/onlinedocs/gcc/Zero-Length.html).
The example at the link gives an idea why this is useful. The
structure can act as a header and the zero length array represents the payload.
The payload can be of variable size but it can still be represented in the
structure.
Ion's use, while valid, is a bit unnecessary since the number of pools is
technically known at compile time. This came in as an ['optimization'](https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=6944561ece14d865238d14e40da858efb29dc2e8)
a few years ago.

Someone submitted a [patch](http://article.gmane.org/gmane.linux.kernel/2217505)
to Ion to extend the page pooling feature for cached pages in addition to
uncached pools, a valuable optimization. This changed the structure to

	struct ion_system_heap {
		struct ion_heap heap;
		struct ion_page_pool *uncached_pools[0];
		struct ion_page_pool *cached_pools[0];
	};

At first glance, this looks okay. The code compiles without warnings.
Just duplicating another structure member.
But this is duplicating a zero length array. The zero length array is supposed
to go at the end of a structure. And what does it mean to have two zero length
arrays?

I ran this question by a few people and the general conclusion was this is
not valid. The actual behavior is about what you would expect from a compiler
(or maybe not):

	$ cat foo.c
	#include <stdlib.h>
	#include <stdio.h>

	struct bad_times {
		int a;
		char *b;
		int *c[0];
		int *d[0];
	};

	int main()
	{
		struct bad_times *uh_oh;

		uh_oh = malloc(sizeof(*uh_oh) + 4 + 5);

		printf(">>> a %p\n", &uh_oh->a);
		printf(">>> b %p\n", &uh_oh->b);
		printf(">>> c %p\n", &uh_oh->c);
		printf(">>> d %p\n", &uh_oh->d);
	}
	$ gcc foo.c
	$ ./a.out
	>>> a 0xce1010
	>>> b 0xce1018
	>>> c 0xce1020
	>>> d 0xce1020
	$

Yes, the two zero size entries alias to the same address. The conclusion is
that since this is undefined behavior the compiler can go ¯\_(ツ)_/¯ and do
whatever it wants. The only way to get any kind of warning is to pass
-pedantic to get "warning: ISO C forbids zero-size array", no warning
about having two of them.

C makes it very easy to get things subtly wrong. Yet another item to add to
your code review checklist. Better yet, don't use zero size arrays unless you
really have to.
