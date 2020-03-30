---
layout: post
title: Rust procedural macros vs gcc plugins
date:   2020-03-30 00:00:00 -0500
---
Much of my work recently has been in [Rust](https://www.rust-lang.org/). I've
known about Rust since its early days but I've never had the inclination to
sit down and work with it until now. In many respects, I feel like I'm working
in a functional programming language given the wide-spread use of `map` and
closures. This may also just be the fact that C provides almost none of these
constructs.

I recently had a problem that I solved using [procedural macros](https://doc.rust-lang.org/reference/procedural-macros.html)
This took a good bit of debugging from me since I'm still coming up to speed
but overall I was pleasantly surprised at the experience. Rust's type system
makes it easy to find errors and didn't let me do anything (too) bad. The
trickiest part for me was figuring out how to go between `proc_macro` and
`proc_macro2` types (again, something that would have been easier with more
Rust experience).

The entire experience really reminded me of doing compiler work and working
with [gcc plugins](https://www.labbott.name/blog/2018/02/28/fun-with-gcc-plugins/).
With both procedural macros and gcc plugins you are making a change to the
generated code. This can be harder than it looks since even simple code can be
hidden by multiple layers of abstraction (how deep do you have to go to just
get the literal). You really need to know exactly what you are expecting and
also handle errors gracefully. In comparison to gcc plugins, Rust makes
doing this significantly easier. The type system is very helpful as a guide
to figure out what needs to be covered as opposed to hoping you caught
everything in a switch statement. Rust also intends for procedural macros
to be widely used by everyone in contrast to gcc plugins which are intended
for a very limited audience. gcc plugins are expected to break across versions
since the ABI is not stable whereas Rust takes care not to make breaking
changes without serious discussion. One notable limitation of Rust macros is
that they are, in fact, macros operating on the syntax. You cannot make changes
at the code generation level or add new optimization passes. Rust does have
[full plugin support](https://doc.rust-lang.org/1.3.0/book/compiler-plugins.html)
though.

Maybe it's a bit unfair to compare C and Rust macros but I do like the idea
of treating macros as an extension of the language instead of just a simple
(and potentially unsafe) transformation.
