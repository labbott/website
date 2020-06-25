---
layout: post
title: So you think you found a compiler bug
date:   2020-06-25 00:00:00 -0500
---
Since started my new [role](https://oxide.computer/) back in January. I have
somehow been hashtag blessed to encounter several compiler bugs. This
is definitely [not](https://www.labbott.name/blog/2017/05/03/when-tools-break-the-kernel/)
the first time I've hit compiler bugs but I've now gotten fairly good at
figuring out when my code may not be the problem.

Most of the bugs I've hit have been related to code generation. Sometimes
the compiler itself may segfault. Obviously if this is happening every time
that's fairly easy to narrow down. Sometimes a compiler segfault may be
intermittent. Before reporting an intermittent compiler fault, please run
a hardware test on your machine. Compilers do a very good job of using a lot
of RAM and have a [history](https://www.tldp.org/FAQ/sig11/html/index.html)
of being a canary for hardware problems. I had this happen with one particular
machine which would occasionally segfault during kernel builds (and in one
notable case flipped a bit on a patch so the subject was "meep track of page
owners" instead of "keep track of page owners"). Sometimes intermittent faults
_are_ real compiler bugs but it's always good to rule out your own problems
first.

In keeping with the theme of "rule out your own problems", one of the best
signs that you might have a compiler bug is if the compiler is doing something
you can't explain. Take this C snippet:

	int a = 4;
	int b = 5;
	int *c = (int *)0x1000;
	*c = (a*b) << 24;

If you were to explain what this code was doing, you might explain this as
"4 gets stored in `a`, 5 gets stored in `b`, 0x1000 gets stored into c,
`a` and `b` get multiplied
together, shifted left by 24 and stored at `c`". Just because you can explain
the code doesn't make it correct though. The value for `a`, `b`, or `c` could
be wrong, you could need to shift by 16, not 24 (you could forget there are
4 bytes in a `u32`...). Finding these bugs may be incredibly tricky but the
important point of bugs in your own code is that you can debug them by updating
your mental model of what's happening. A compiler bug throws this model
completely off.

Your high level code gets compiled to assembly. You can use `objdump` to
look at the assembly of an executable or use `gcc -S` to have gcc stop at the
assembly stage. (If you're debugging in the Linux kernel you can do `make
path/to/kernel/file.s`)
Assembly language is a language unto itself and takes some
practice to read (but you can learn it!) If you were running this snippet
on an ARM platform that code might get compiled to

	mov r0, #4 // Move 4 into register 0
	mov r1, #5 // Move 5 into register 1
	mov r2, #4096 // Move 0x1000 into register 2
	mul r0, r0, r1 // Multiple r0 and r1 and store the result in r0
	lsl r0, r0, #24 // Shift r0 left by 24
	str r0, [r2]  // store the value of r0 at the address held by r2

A little bit hard to read but it maps closely to what the C code is trying
to do. Now imagine instead the compiler put out this code:

	mov r0, #4 // Move 4 into register 0
	mov r1, #5 // Move 5 into register 1
	mov r2, #4096 // Move 0x1000 into register 2
	mul r0, r0, r1 // Multiple r0 and r1 and store the result in r0
	str r0, [r2]  // store the value of r0 at the address held by r2
	lsl r0, r0, #24 // Shift r0 left by 24

Here, the compiler has (incorrectly) put the store before the shift. That's
going to have a much different (and surprising) effect! Trying to debug
a problem like this ends up coming down to checking your assumptions at
every step with a debugger or printf (and hoping neither of those change
your state). What do you expect to be happening at each line of the code
and does the assembly match your assumptions? That's what you need to be
asking yourself to debug a problem like this.

So if you can't explain why the compiler emitted some assembly does that
mean you found a compiler bug? Not necessarily. The above snippet I gave
above was clearly wrong but high level languages don't always map quite
as nicely to assembly. C, in particular, has a history of undefined behavior.
Relying on undefined or underspecified behavior is a great way to be surprised
by the compiler. Determining if you've found a bug or just unexpected behavior
usually involves talking to the compiler/language team. You _can_ debug a
compiler yourself but modern compilers have enough passes and optimizations
it can be hard to guess which part is responsible. One key point to remember
about reporting a compiler issue is that the compiler team doesn't know your
code base so if you can narrow down the test case to something small that's
always best. For gcc, you can pass `-E` to stop at the preprocessing stage and
give you a self-contained file ending in `.i`.
(For the Linux kernel you can do `make path/to/kernel/file.i`).

This is (kind of) the story behind the latest bug that inspired this
blog post. I was debugging an issue (in Rust not C!) where I was seeing
a variable changing after a system call that should not have affected
the variable at all. It took a some dumping of assembly to
realize the read of the variable after the system call was using a register
that was not getting saved. Specifically, the code was using the frame
pointer as general purpose register and the compiler was handling this
[incorrectly](https://github.com/rust-lang/rust/issues/73450). This is a good
reminder that like other code, compilers often have issues around edge cases.
Compilers are also usually very diligent about having tests for everything to
avoid regressions later. Inline assembly is also a particularly troublesome
feature since it involves messing with the compiler's register allocator at a
pretty fundamental level. Once again, my hats off to all the compiler engineers
who make sure that the rest of us (almost) never have to worry about what
the compiler is doing.

I wrote this post with compiler bugs in mind but much of this applies to
hardware bugs as well. You are assuming certain behavior out of the hardware
and if it's not doing what you expect it can be very hard to debug. Figuring
out what assumptions you're making (even implicitly) and where those
assumptions are breaking down is a critical debugging skill.
