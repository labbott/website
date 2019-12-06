---
layout: post
date: 2016/09/15 11:00:00
title: Secure(ish) boot with QEMU
category: fedora
---
(Edit 9/21: I've gotten some feedback and clarifications about a few steps and
also updated the wiki. Thanks to the OVMF developers!)

Despite having too many machines in my possession, none of the x86
machines I have are currently set up to boot with UEFI. This put a real damper
on my plans to poke at secure boot. Fortunately, there is virtualization
technology to solve this problem. I really like being able to boot kernels
[directly](http://www.labbott.name/blog/2016/04/22/quick-kernel-hacking-with-qemu-+-buildroot/)
without a full VM image. There are some [instructions](https://fedoraproject.org/wiki/Using_UEFI_with_QEMU)
for getting started but they are a bit incomplete for what I wanted to do.
This is what I used to get secure boot working (or at least detected) in QEMU.
I make no guarantees about it actually being secure or signed correctly but
it's a starting point for experiments.

The secure boot firmware is available as part of the standard Fedora package.

	$ sudo dnf install edk2-ovmf

You need to tell QEMU to pick up the firmware and emulate a file for storing
EFI variables. The firmware used here is going to be `OVMF_CODE.secboot.fd`.

	$ cp /usr/share/edk2/ovmf/OVMF_VARS.fd my_vars.fd

This creates a copy of the base variables file for modification and use. The
options you need to append to QEMU are (with some comments in #)

	# required machine type
	-machine q35,smm=on,accel=kvm
	# Due to the way some of the models work in edk2, we need to disable
	# s3 resume. Without this option, qemu will appear to silently hang
	# althouh it emits an error message on the ovmf_log
	-global ICH9-LPC.disable_s3=1
	# Secure!
	-global driver=cfi.pflash01,property=secure,value=on
	# Point to the firmware
	-drive if=pflash,format=raw,unit=0,file=/usr/share/edk2/ovmf/OVMF_CODE.secboot.fd,readonly=on
	# Point to your copy of the variables
	- drive if=pflash,format=raw,file=/home/labbott/my\_vars.fd

I added these to the [existing command](http://www.labbott.name/blog/2016/04/22/quick-kernel-hacking-with-qemu-+-buildroot/)
I had for QEMU. I bumped the memory on the KVM command line to 500 as well
(`-m 500`). If all goes well, you should be able to boot a kernel and have it
detect EFI (`dmesg | grep EFI`) with this setup.

To actually enable secure boot, we need to run an EFI program to load a set
of certificates. The default Fedora build provides a nice .iso with the UEFI
shell and EFI application built in, `/usr/share/edk2/ovmf/UefiShell.iso`.
Add `-hda /usr/share/edk2/ovmf/UefiShell.iso` to your QEMU command and remove
the `-kernel` and `-initrd` options. If all goes well, you should be dropped
into the UEFI shell. You can now run the command to add keys

	Shell> FS0:
	FS0:\> EnrollDefaultKeys.efi

Your vars file should now be all set up for secure boot. If you boot with a
`-kernel` and `-initrd` option, you should be able to boot a kernel
and have it detect secure boot (`dmesg | grep Secure`).

Booting your own kernels isn't too difficult. If you take a [tree](https://git.kernel.org/cgit/linux/kernel/git/jwboyer/fedora.git/)
that has secure boot patches in it, make sure the following set of options is
enabled

	CONFIG_SYSTEM_DATA_VERIFICATION=y
	CONFIG_SYSTEM_BLACKLIST_KEYRING=y
	CONFIG_MODULE_SIG=y
	CONFIG_MODULE_SIG_ALL=y
	CONFIG_MODULE_SIG_UEFI=y
	CONFIG_MODULE_SIG_SHA256=y
	CONFIG_MODULE_SIG_HASH="sha256"
	CONFIG_ASN1=y
	CONFIG_EFI_STUB=y
	CONFIG_EFI_SECURE_BOOT_SIG_ENFORCE=y
	CONFIG_ASYMMETRIC_KEY_TYPE=y
	CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
	CONFIG_X509_CERTIFICATE_PARSER=y
	CONFIG_PKCS7_MESSAGE_PARSER=y
	CONFIG_SIGNED_PE_FILE_VERIFICATION=y
	CONFIG_EFI_SIGNATURE_LIST_PARSER=y
	CONFIG_MODULE_SIG_KEY="certs/signing_key.pem"
	CONFIG_SYSTEM_TRUSTED_KEYRING=y
	CONFIG_SYSTEM_TRUSTED_KEYS=""

This will be enough for the kernel to detect that secure boot is enabled
and let you experiment with things. You can even issue your own pesign
command

	$ pesign -c 'Red Hat Test Certificate' --certdir /etc/pki/pesign-rh-test -i arch/x86/boot/bzImage -o vmlinuz.signed -s

