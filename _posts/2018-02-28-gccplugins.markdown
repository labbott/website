---
layout: post
date: 2018/02/28 11:00:00
title: Fun with gcc plugins
category: fedora
permalink: /blog/2018/02/28/fun-with-gcc-plugins/
---
One of piece of infrastructure that's come in as part of the
[Kernel Self Protection Project (KSPP)](https://kernsec.org/wiki/index.php/Kernel_Self_Protection_Project)
is support for gcc plugins. I touched on this briefly in my [DevConf talk](https://www.youtube.com/watch?v=x3hOcneZjiE)
but I wanted to discuss a few more of the 'practicalities' of dealing with
compiler plugins.

At an incredibly abstract level, a compiler transforms a program from some form
`A` to another form `A'`. Your `A` might be C, C++ and you expect `A'` to be
a binary file you can run. Modern compilers like gcc produce the final result
by transforming your program several passes, so you end up with `A` to `A'` to
`A''` to `A'''` etc. The gcc plugin architecture allows you to hook in at
various points to make changes to the intermediate state of the program.
gcc has a [number](https://gcc.gnu.org/onlinedocs/gccint/index.html) of
internal representations so depending on where you are hooking you may need
to use a different representation.

Kernel development gets a (not undeserved) reputation for being poorly
documented and difficult to get into. To write even a self-contained kernel
module requires some knowledge about the rest of the code base. If you have
some familiarity with the code base it makes things much easier. I've found
compiler plugins to be similarly difficult. I'm not working with the gcc
code base on a regular basis so figuring out how to do something practical
with the internal structures feels like an uphill battle. I played around
with writing a toy plugin to look at the representation and it took me
forever to figure out how to get the root of the tree so I could do something
as simple as call `walk_tree`. Once I figured that out, I spent more time
figuring out how to actually do a switch on the node to see what type it was.
Basically, I'm a beginner in an unfamiliar code base so it takes me a while
to do anything.

Continuing the parallels between kernels and compilers, the internal ABI of
gcc may change between versions, similar how the kernel provides no stable
internal ABI. If you want to support multiple compiler versions in your plugin,
this results in an explosion of `#ifdef VERSION >= BLAH` all throughout the
code. Arguably, external kernel modules have the same problem but I'd argue
the problem is slightly worse for compiler plugins. Kernel modules can be
built and shipped for particular kernel versions but it's harder to require
specific compiler versions.

With all this talk about how hard it is to use compiler plugins, there might
be some questions about if it's really worth it to support them at all. My
useless answer is "it depends" and "isn't that the ultimate question of any
feature". If you have a plugin that can eliminate bug classes, is it worth
the maintenance burden? I say yes. One long term option is to get features
merged into the main gcc trunk so they don't have to be carried as plugins.
Some of the tweaks are kernel specific though, so we're probably stuck carrying
the more useful plugins.
There is [interest](http://www.openwall.com/lists/kernel-hardening/2018/02/27/33)
in new compiler flags and features so we'll have to see what happens in the
future.
