---
layout: post
date: 2016/02/09 16:00:00
title: Kernel self protection introduction
category: fedora
permalink: /blog/2016/02/09/kernel-self-protection-introduction/
---
At the last kernel summit, Kees Cook started calling for people to participate
in the ["Kernel Self Protection Project"](https://lwn.net/Articles/663361/)
to increase security or 'harden' the kernel.
The goal is to focus on eliminating classes of security bugs or reducing
the impact of those bugs. This is a slightly different goal than just finding
and fixing security bugs. As long as developers are writing code, there are
going to be security bugs. There is no way around this. "Self Protection"
involves making sure that these bugs can't be used as part of an exploit. A
classic example is the buffer overflow:

	#include <stdio.h>

	int main(int argc, char **argv)
	{
		char buffer[10];

		gets(buffer);
		printf("you said %s\n", buffer);
		return 0;
	}

For those who haven't seen this before, `gets` is a function which reads
characters from stdin and stores them in `buffer`. There's no bounds checking
involved on `gets` which means that it's easy to write outside the buffer.
(Give it “a” and it’s fine. Give it “aaaaaaaaaaaaaaaaaaaaaaaaaaaa” and you’ve
overrun the buffer)
In
this example, `buffer` is stack allocated which means that the corruption is
going to happen on the stack. A clever attacker could use this to overwrite
the return address on the stack and execute their own code in the buffer or
jump to another location.

How would hardening features help here? Under normal circumstances, code should
never run on the stack. Marking the stack as non-exectuable would prevent an
attacker from running their own code. This still would not prevent a jump to
other executable code though. An attacker needs to figure out where to jump
to in order to do something 'interesting'. Randomization of code would make it
more difficult to figure out where to jump. The end result of hardening is that
there is still a bug to be fixed but the security implications are
significantly reduced.

Many of the protections being discussed for the kernel are coming out of the
[grsecurity patches](https://en.wikipedia.org/wiki/Grsecurity). These patches
have been around for a very long time and provide a set of modern security
features. The question always comes up "but why aren't they in the mainline
kernel if they are so useful?". The simplest answer is that the authors and the
kernel maintainers never came to an agreement about the patches so they were
never merged. (The full history is available in various mailing lists for those
who are interested. Google will find you plenty of interesting reading.)
The patch authors have been doing the hard work of
rebasing and reworking the patches to work with newer kernel versions ever
since.

The hope is that this new push will lead to some of the grsecurity features
being moved into mainline so more people can benefit from increased security.
So far, a few features have been pulled out and sent out for review. Kernel
development is an iterative process and a good amount of feedback has been
given. The key is persistence in taking the feedback and continuing to send
out new versions of the patches. I'll talk in a later post about my own
experience in sending out patches for this project.  The
[self protection wiki](http://kernsec.org/wiki/index.php/Kernel_Self_Protection_Project)
has more details about the overall project in depth and the types of problems
being looked at.
