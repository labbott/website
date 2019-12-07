---
layout: post
date: 2016/12/20 11:00:00
title: Chatty kernel logs
category: fedora
permalink: /blog/2016/12/20/chatty-kernel-logs/
---
Most people don't care about the kernel until it breaks or they think it is
broken. When this happens, usually the first place people look is the kernel
logs by using `dmesg` or `journalctl -k`. This dumps the output of the in-
kernel ringbuffer. The messages from the kernel ring buffer mostly come from
the kernel itself calling `printk`. The ring buffer can't hold an infinite
amount of data, and even if it could more information isn't necessarily better.
In general, the kernel community tries to limit kernel prints to error messages
or limited probe information. Under normal operation the kernel should be
neither seen nor heard. The kernel doesn't always match those guidelines though
and not every kernel message is an urgent problem to be fixed.

The kernel starts dumping information almost immediately after the bootloader
passes it control. Very early information is designed to give an idea what
kind of kernel is running and what kind of system it is running on. This may
include dumping out CPU features and what areas of RAM were found by the
kernel. As the kernel continues booting and initializing, the printed messages
get more selective. Drivers may print out only hardware information or nothing
at all. The latter is preferred in most cases.

I've had many arguments on both sides about whether a driver should be printing
something. There's usually a lot of "but my driver reaaaallly needs this". The
preferred solution to this problem is usually to adjust the log level the
messages are printed at. The kernel provides [several](https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/Documentation/kernel-parameters.txt?id=refs/tags/v4.9#n2145)
log levels to filter out appropriate messages. Most drivers will make use
of `KERN_ERR` `KERN_WARN` and `KERN_INFO`. These have the meaning you would
expect: true errors, just gentle warning and some useful information.
`KERN_DEBUG` should be used to provide more verbose debugging/tracing on an as
needed basis. The kernel option `CONFIG_DYNAMIC_DEBUG` can be used to
[enable and disable](https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/Documentation/dynamic-debug-howto.txt?id=refs/tags/v4.9)
individual `pr_debug` messages at runtime. This option is enabled on Fedora
kernels.

Even with the different levels of kernel messages available, it may not always
be clear how important a message actually is. It's very common to get Fedora
kernel bug reports of "dmesg had message X". If there is nothing else going
wrong on the system, the bug may either get closed as `NOTABUG` or placed at
low priority. A common ongoing complaint is with firmware. Drivers may look for
multiple firmware versions, starting with the newest. If a particular firmware
isn't available, the firmware layer itself will spit out an error even if a
matching version may eventually be found. Sometimes the kernel driver may not
match the hardware exactly and the driver will choose to be 'helpful' and
indicate there may be problems. While it is true that hardware which is not
100% compliant may cause issues, messages like this are unhelpful without a
message that this isn't likely to be fixed in the kernel. Even with statements
like "the kernel is fine", it can be confusing and difficult to explain this
to users.

The kernel logs are a vital piece of information for reporting problems. Not
all messages in the logs are an indication of a problem that needs a kernel fix.
It's still important to report bugs so we know what bothers people. It may be
possible to report issues to upstream driver owners to report better error
messages and make the kernel logs more useful for everyone.
