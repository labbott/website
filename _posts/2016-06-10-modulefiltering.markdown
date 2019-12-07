---
layout: post
date: 2016/06/10 16:00:00
title: Module filtering and depmod
category: fedora, rawhide
permalink: /blog/2016/06/10/module-filtering-and-depmod/
---
Rawhide has been quiet since the first week of the merge window.
The 2nd week had a smattering of kernel options to be enabled but almost no
conflicts. -rc1 and -rc2 have been fairly easy as wel. The most
significant work was getting the module filtering correct last week.

Sometime in 2014 the kernel was split up into kernel-core and kernel-modules
subpackages. The motivation was that systems that wanted a smaller footprint
(e.g. cloud) could install only the kernel-core package and get a reasonably
running system. Kernel modules are just chunks of kernel-code that get
loaded at runtime. Modules are not completely self-contained though. They have
dependencies on the core kernel and possibly other modules[^1].

The depmod tool is designed to find dependency problems (among other uses).
The Fedora kernel flow goes roughly

- build modules

- generate a list of modules using some shell scripts. That list is what will
go in kernel-modules.

- take that list of modules out of the tree. What's left will go in kernel-core.

- run depmod to verify all modules still in kernel-core are still loadable.

Typically problems arise when new modules are added or modules are renamed.
Case in point cxgbit from 4.7.0-0.rc1.git1.1.fc25 (edited slightly for ease
of reading):

	depmod: WARNING: drivers/target/iscsi/cxgbit/cxgbit.ko needs unknown symbol cxgb4_clip_get
	depmod: WARNING: drivers/target/iscsi/cxgbit/cxgbit.ko needs unknown symbol cxgb4_l2t_send
	depmod: WARNING: drivers/target/iscsi/cxgbit/cxgbit.ko needs unknown symbol cxgb4_port_viid
	depmod: WARNING: drivers/target/iscsi/cxgbit/cxgbit.ko needs unknown symbol cxgb4_alloc_stid
	depmod: WARNING: drivers/target/iscsi/cxgbit/cxgbit.ko needs unknown symbol cxgbi_ppm_init
	depmod: WARNING: drivers/target/iscsi/cxgbit/cxgbit.ko needs unknown symbol cxgb4_ofld_send
	depmod: WARNING: drivers/target/iscsi/cxgbit/cxgbit.ko needs unknown symbol cxgb4_remove_tid
	depmod: WARNING: drivers/target/iscsi/cxgbit/cxgbit.ko needs unknown symbol cxgb4_port_chan
	depmod: WARNING: drivers/target/iscsi/cxgbit/cxgbit.ko needs unknown symbol cxgb4_unregister_uld
	depmod: WARNING: drivers/target/iscsi/cxgbit/cxgbit.ko needs unknown symbol cxgb4_free_stid
	depmod: WARNING: drivers/target/iscsi/cxgbit/cxgbit.ko needs unknown symbol cxgbi_ppm_ppod_release
	depmod: WARNING: drivers/target/iscsi/cxgbit/cxgbit.ko needs unknown symbol cxgb4_create_server6
	depmod: WARNING: drivers/target/iscsi/cxgbit/cxgbit.ko needs unknown symbol cxgb4_l2t_release
	depmod: WARNING: drivers/target/iscsi/cxgbit/cxgbit.ko needs unknown symbol cxgb4_clip_release
	depmod: WARNING: drivers/target/iscsi/cxgbit/cxgbit.ko needs unknown symbol cxgbi_ppm_ppods_reserve

The cxgbit module was enabled in the kernel config but other modules it depends
on were filtered into the kernel-modules package. The fix is usually simple,
just filter the cxgbit module into the kernel-modules subpackage. Sometimes
it takes [multiple](http://pkgs.fedoraproject.org/cgit/rpms/kernel.git/commit/?id=57618355c45385dc8af51e0cee8d12dbcb2d0aca)
[tries](http://pkgs.fedoraproject.org/cgit/rpms/kernel.git/commit/?id=0d45f1a0bdf571f109bb6c06620964e74caa8280)
[to actually get right](http://pkgs.fedoraproject.org/cgit/rpms/kernel.git/commit/?id=6a51c81bc3227e8e7b9ddb9cd237709a215eb045).
As of this writing there was still a similar issue with powerpc as well.

Testing the module filtering tends to be a slow process because it comes at
the end of the build. It's not easy to restart partially because modules are
removed from the tree. Longer term, I'd like to figure out a better way to
aid in debugging filtering problems.

[^1]: Those dependencies are one reason why out of tree modules are a royal
pain. In tree modules will get API/rename/whatever updates automatically.
Out of tree modules will not. Consider this your periodic PSA about out of
tree modules and why supporting them is hard.
