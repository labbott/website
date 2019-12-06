---
layout: post
date: 2015/12/17 16:00:00
title: Building and adding patches to the Fedora kernel
category: fedora, kernel
---
Inevitably, after finding an interesting patch file it's time to actually
add it to the Fedora kernel. The kernel team has tried our best to keep
the wiki instructions up to date.  The
[build dependencies](https://fedoraproject.org/wiki/Building_a_custom_kernel#Dependencies_for_building_kernels)
have changed of late so double check those, especially if you get pesign
errors. The
[instructions for building from Fedora kernel source](https://fedoraproject.org/wiki/Building_a_custom_kernel#Building_a_Kernel_from_the_Fedora_source_tree)
are still accurate. To summarize from the wiki

- Make sure you have all dependencies installed. If something fails, double
check this again
- `$ fedpkg clone -a kernel`
- `$ cd kernel`
- `$ git checkout origin/(release)` (e.g. origin/f22, origin/f23, origin/master
for rawhide)

In the kernel.spec file, it's good practice to change the line

`# define buildid .local`

to

`%define buildid .local`

which will add an extra tag to avoid conflicts with existing kernel packages.
You can change the `.local` to another more descriptive name.

This is now a a pkg-git tree for the Fedora kernel. The wiki page on the
[kernel.spec file](https://fedoraproject.org/wiki/Kernel/Spec#Individual_patches)
gives an overview about how to add patches. To summarize:

- copy the .patch file to the pkg-git directory
- search for `END OF PATCH DEFINTIONS`
- Identify the number of the last patch definition. The patch you add will have
have number plus 1.
- Add a line `Patch<number +1>: your-patch-name.patch`
- For F22 and earlier, search for `END OF PATCH APPLICATION` and add
`ApplyPatch your-patch-name.patch`

The tree can now be built with

`$ fedpkg local`

and installed with

`$ dnf install --nogpgcheck ./x86_64/kernel-$version.rpm`

(changing the x86_64 to your arch if necessary).

If you aren't interested in RPMs,
the [exploded tree](https://git.kernel.org/cgit/linux/kernel/git/jwboyer/fedora.git/) has all the patches applied on top. You can use `git am` to apply other
patches and then build the kernel. Sample commands:

- `$ cp fedora/configs/kernel-(version)-(arch).config .config`
- `make -j4`
- `sudo make modules_install`
- `sudo make install`

