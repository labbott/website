---
layout: post
date: 2015/09/10 16:00:00
title: Debugging modprobe in dracut
category: fedora
permalink: /blog/2015/09/10/debugging-modprobe-in-dracut/
---
Related to bisection, I've been working on some custom packaging of the
kernel. This has basically involved hacking away at the existing kernel.spec
file until I get something that's usable and does what I want. My latest
attempt finally resulted in an rpm that installs without errors. Exciting!
When I went to test boot though I dropped into the dracut shell. journalctl
showed me the error:

```
device-mapper: table: 253:0: crypt: unknown target type
```

Googling told me that this meant the dm-crypt kernel module was not found.
Yet in the dracut shell I could see the module where I expected it to be.
I tried running modprobe manually:

```
dracut:/# modprobe dm-crypt
dracut:/#
dracut:/# echo $?
1
dracut:/# modprobe -v dm-crypt
dracut:/#
dracut:/# modprobe -v sdfsdfsdfsdfds
dracut:/#
```

Typically, I would expect modprobe to give some kind of message like
`modprobe: FATAL: Module sdfsdfsd not found.` so the fact that it
was giving me nothing was baffling. Nothing in `journalctl` either.
strace is a useful tool for these types of problems except it
isn't included by default in dracut. This was fixed with an update
of the initrd outside of dracut:

```
# cp /boot/initramfs-<kversion>.img /boot/initramfs-backup.img <kversion>
# dracut --force --install 'strace' /boot/initramfs-<kversion>.img
```

Now the usual `strace -o out modprobe dm-crypt` gave me the answer
I was looking for: As part of my hacking I changed the name of the
folder where the modules are stored. By default, modprobe looks
for the modules in /lib/modules/`uname -r` . Apparently if it
can't find any of the usual modules.* files at that location it just
dies silently with no output whatsoever. How useful. But if I pass
the correct `-S` flag to modprobe I get the expected output about
modules not loading. Arguably, this behavior is all described in the
man page for modprobe but I still needed a more obvious hint to
figure it out.

For more fun about why this went wrong, `unknown target type` is
the error message from `dm_get_target_type` in `dm_table_add_target`.
`dm_get_target_type` checks if the module is availble, if not it
calls `load_module` -> `request_module` -> `__request_module` -> `call_modprobe`
which does about what you think it does. This means that anything
which relies on passing `-S` isn't going to work out of the box
for dm-crypt or any other kernel subsystem which calls `request_module`

Back to some brainstorming for me.
