---
layout: post
date: 2016/03/01 16:00:00
title: Upstreaming in steps
category: fedora
---
I previously discussed the [kernel self protection project](http://www.labbott.name/blog/2016/02/09/kernel-self-protection-introduction/).
As part of this, I've been looking at free memory sanitization. This task is
a great example about how features actually get into the kernel.

First, a description of sanitization. Under typical
operation, when memory is freed back to the heap nothing happens to the data
left in the memory. What's there will remain there. If an attacker manages
to find a use-after-free or arbitrary read bug, the attacker may be able
to read whatever is sitting around in free memory. This can be harmless or
very bad depending on what's there. If what's sitting around
in free memory is encryption keys, someone is in for a very bad day. An easy
way to reduce risk here is to clear the memory (sanitize) on free. This way,
any sensitive data is no longer available for an attacker to get. This is a
great example of what the self protection project is trying to do: issues
such as arbitrary read and use-after-free are still bugs that need to be
fixed but their risk can be reduced somewhat with sanitization.

Sanitization is not a new idea. Grsecurity has had it for some time. I have
some background in working with kernel memory management already so it
was a good match of my skills to a missing feature. Given Grsecurity had
a working implementation of this already, I elected to use that as a starting
point for the first submission. Typically, the upstream community likes
features as small separate patches which can be reviewed individually. The
Grsecurity patch is not structured this way so getting it in a form which
could be submitted involved picking pieces out of the mega patch and turning
those pieces into smaller patches. This is similar to doing a backport of a
patch and much of the same [thought processes](http://www.labbott.name/blog/2015/11/06/the-work-of-maintaining-a-kernel-tree/)
apply here as well (i.e. blindly copy pasting will lead to trouble).

Once the patches were completed and sent out, the reviewers had a lot to say.
The first thing that popped up was "why is this necessary, we have slub_debug
already". This is a very common occurrence when having patches reviewed: as
the patch author you know why you want the patch submitted but the reviewers
can't read your mind. Well written commit text and cover letters go a long
way towards understanding but questions will still come up. My thought was
there was too much other 'debug' work being done with slub debug to make it
useful as a security feature even though it did provide the necessary
functionality.  The slub maintainer disagreed and requested I make
use of the existing infrastructure and fix up issues instead of adding new
code. In general if a maintainer says no, you have to be really convinced that
you are right to continue arguing and win. Maintainers have to be looking out
for more than just your feature so they usually have good reason to say no.
I had considered the exact suggestion when I was starting out so I didn't
see a good reason to continue arguing my case.

One of the biggest concerns with sanitization is performance. Doing an
extra memset on every free is going to be an expensive operation. The existing
slub_debug infrastructure only used the slow path of allocation as well 
which has a notable impact on performance. The next version of my patch
series added an option to let the debugging happen on the fast path instead of
just the slow path. The
slub allocator is well tuned and very performance sensitive so adding anything
extra could impact benchmarks. I set up the change behind a Kconfig option so
those who wanted the old behavior could turn it off. When I measured some
benchmarks they didn't seem to be affected much. I considered the minor
difference a trade off of performance vs. a security feature.

The slub maintainer had a different opinion though. The difference while
small was still an increase which was considered unacceptable. The request
was to work on making the slow path faster instead of impacting the fast path.
This, again, goes back to the point that maintainers have to be looking out
for the entire code base and not just one feature. It's frustrating to hear but
ultimately it makes the overall kernel better. The maintainer also had good
feedback on a few other parts of the series. This is another advantage of
breaking down the patches into smaller parts: it's easier to indicate which
parts are okay with a little bit of work and which parts need a new approach.

Most of the existing optimization in the slub allocator has occurred on the
fast path. Nobody has really looked at the optimization of the debug path at
all. It was pretty easy to find several spots where performance could be
improved. The slub maintainer agreed and Acked the patches. This was a nice
milestone for the sanitization feature. There's still more work to be done to
get it to match the level of Grsecurity in terms of coverage and performance.

So what are the lessons here?

- Kernel development is iterative. It generally takes more than one patch
version to get anything beyond the simples features accepted.
- Be persistent. It's easy to let a feature fall off because a maintainer says
no but if you really want it to go in you have to keep working with the
feedback.
- Small steps are much easier to deal with than huge changes
- What you end up with may look completely different than what you started
with. The larger goal is more important than the individual patches.
- Take the bigger picture into account when working on features. Think about
what else might be affected. How might the maintainers react?
- Make a choice about a design and then go with it. It's easy to get bogged
down trying to figure out what's the best design. Sometimes you won't actually
know until you ask others so do the best you can.
- This entire process only works when there is positive communication. It's
important to say that an approach won't work and it's important that
the message come across respectfully. You do not have to compromise on either
part.
