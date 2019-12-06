---
layout: post
date: 2015/12/14 16:00:00
title: It's okay, break your kernel
category: fedora, kernel
---
For those who haven't worked on it before, the kernel can give off an aura
of mystery. It's a black box that gives error codes back when you don't make
system calls right. This has the unfortunate tendency to put kernel developers
on a pedestal: they know the secrets, they must be hard core hackers to do
kernel work. 

The reality is much simpler: the kernel is a software project. There is
nothing particularly special about being a kernel developer. Jumping into
any code base is going to involve a learning curve. You don't need to be
[the best programmer ever](https://lwn.net/Articles/641779/) to make
modifications. The core kernel is completely self-contained in one project
which means fewer dependencies than a lot of userspace projects.
(yes, there are modules out of tree but the most important parts are in
a single project). The self-contained nature means that it's easy to switch
back to a stable kernel from an unstable one which makes testing easier.

It's okay to screw up and have the kernel crash.
In the same way good judgement comes from experience and experience comes from
bad judgement, stable patches come from debugging, and debugging comes from
unstable patches. Having the kernel crash isn't always fun since
[files](http://danluu.com/file-consistency/) can become corrupt. The key is
to figure out an environment where it won't have a impact. Once you figure out
that environment, crashing a kernel is no more dangerous than a segfault in
userspace. The kernel git
history is full of patches that crashed. This isn't an endorsement to commit
untested, half-baked patches; the point is that if you try something in the
kernel and you get a crash, you are in good company.

The overall point of this post is that if you are curious about the kernel,
don't be afraid to try something on your own. Communicating with the kernel
community isn't required unless you want to. There isn't a magic qualification
test to pass to poke at the kernel. The
[Eudyptula challenge](http://eudyptula-challenge.org) is a great way to get
started. [Kernel Newbies](http://kernelnewbies.org) has good resources as well.
I have a couple of blog posts in the works talking about getting patches and
applying them to build a Fedora kernel. If you like it the kernel, break it!
