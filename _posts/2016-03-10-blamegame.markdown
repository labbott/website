---
layout: post
date: 2016/03/10 16:00:00
title: The kernel blame game
category: kernel, fedora
permalink: /blog/2016/03/10/the-kernel-blame-game/
---
Fedora is a system of many individual pieces, each of which can affect the
others. The kernel is usually fairly self-contained, or at least it tries to be.
 This is a story of two issues triggered by two different kernel changes that
show the kernel is not an entity unto itself.

Major kernel version upgrades usually bring out issues and 4.4 was no different.
A user filed a bug about a change in behavior: disk partitions on the hard
disk were now being mounted automatically. This behavior was unwanted as those
partitions previously required root to mount. The kernel is
responsible for setting up device nodes but ultimately userspace is responsible
for making the system calls to actually mount filesystems past a certain point.
The system logs were clearly showing udisksd was making the request to mount
those partitions. This really didn't look like a kernel issue so I suggested
some other userspace setting had changed the automounting options. The reporter
downgraded other userspace packages that had been installed at the same time
but this showed no change. Installing just the kernel was enough to change
the behavior so something in the kernel must have changed.

Debugging often involves working backwards to figure out how we got somewhere.
Working backwards here:

- Partitions are being mounted
- The logs are showing the mount requests coming from udisksd
- udisksd is triggering the mount requests
- udisksd uses ????? to decide what to mount

I bounced this problem off of my teammates and they suggested the partition
options could be coming up differently based on the kernel. So what partition
options was udisks reading to figure out what to mount? The udisks
documentation wasn't very useful. It gave great examples of how to change the
automounting behavior but it didn't answer the question of how it sets the
defaults. I eventually found the `udisksctl dump` command which shows what
state udisks has for all the partitions it knows about. This was really
insightful: in the non-working kernel udisks was marking the parititions as
automount and removable which explained the behavior. It didn't explain why
it was making those decisions though. Looking at the code is my preferred
method for understanding some behaviors. The udisks code was less enlightening
than I would have liked. All I could tell was that some call was returning
that the disk was removable. On a whim, I decided to look through the kernel
commit history and found a [commit](https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=8a3e33cf92c7b7ae25c589eccd1a69ab11cc4353)
which matched the exact behavior and a revert confirmed this was the breaking
patch. The ultimate issue was that marking the drive as hotplug capable was
enough to get the drive marked as removable. The original patch author
provided a [fix](https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/?h=linux-4.4.y&id=a55479ab637cda5ebbfdb9eb7c062bd99c13d5d9)
to not mark hotplug ports as removable.

During the course of discussion on bugzilla, a second person was reporting
the same issue. The fix did not work for this reporter though so we started
a different bug for tracking. In this case, the behavior and bug was
different: the kernel would boot but eventually dracut would spit out a message
that it can't find the lvm partitions. A good starting point for issues where
root partitions won't mount is to drop into the
[dracut shell](https://fedoraproject.org/wiki/How_to_debug_Dracut_problems#Using_the_dracut_shell).
This lets you run shell commands to collect system information. Ultimately
though someone else reported the same issue in parallel and found the issue
before any debugging took place. In 4.4, the mpt2sas driver was replaced with
the mpt3sas driver. The kernel has alias to take care of loading mpt3sas when
`modprobe mpt2sas` happens. The mpt3sas module needs to be present for this
to work though. Each time a new kernel is installed, dracut uses the set of
existing loaded modules to figure out what to put in the initramfs.
(Live CDs have a huge number of kernel modules in the initramfs to be able
to run on almost any platform and give a base for installing the kernel).
dracut didn't detect the name change so the mpt3sas module wasn't
present in the initramfs, preventing the file system from being mounted. The
workaround is fairly straight forward: put the mpt3sas module into the
initramfs. Once it is in place, dracut will correctly add it to all future
initramfs that are generated. Ultimately though, dracut needs to properly
follow module aliases for modules which are no longer present.

Lessons here:

- The kernel is not always right. Kernel changes need to be aware of userspace
assumptions and not break them. The kernel community usually tries very hard
not to introduce regressions but they do sometimes happen.
- The kernel is not alway wrong. Sometimes a kernel change can expose a
limitation in another program which needs to be fixed.
- Knowing debugging techniques outside the kernel is necessary for kernel
developers, or at least Fedora kernel maintainers.
- Sometimes you get really really lucky in finding an answer to your problem
- Early testing of updates in bodhi and good bug reporting helps to find issues
fast and get them fixed quicker. Both of these issues were reported, and in the
once case fixed, by the 2nd stable release for 4.4.
