---
date: 2016/09/15 11:00:00
title: Secure(ish) boot with QEMU
categories: fedora
---
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

The QEMU firmware is now available in regular Fedora repos but the full secure
boot firmware isn't from what I can tell. You need to install the nightly
firmware.

	$ sudo dnf install dnf-plugins-core
	$ sudo dnf config-manager --add-repo http://www.kraxel.org/repos/firmware.repo
	$ sudo dnf install edk2.git-ovmf-x64

You need to tell QEMU to pick up the firmware and emulate a file for storing
EFI variables. The firmware used here is going to be `OVMF_CODE-need-smm`.

	$ cp /usr/share/edk2.git/ovmf-x86/OVMF_VARS-need-smm.fd my_vars.fd

This creates a copy of the base variables file for modification and use. The
options you need to append to QEMU are (with some comments in #)

	# required machine type
	-machine q35,smm=on,accel=kvm
	# S3 state must be disabled. QEMU hangs silently without this
	-global ICH9-LPC.disable_s3=1
	# Secure!
	-global driver=cfi.pflash01,property=secure,value=on
	# Point to the firmware
	-drive if=pflash,format=raw,unit=0,file=/usr/share/edk2.git/ovmf-x64/OVMF_CODE-need-smm.fd,readonly=on
	# Point to your copy of the variables
	- drive if=pflash,format=raw,file=/home/labbott/Downloads/virt-efivars-HEAD-c520b89/example-varstore-edited

I added these to the [existing command](http://www.labbott.name/blog/2016/04/22/quick-kernel-hacking-with-qemu-+-buildroot/)
I had for QEMU. I bumped the memory on the KVM command line to 500 as well
(`-m 500`). If all goes well, you should be able to boot a kernel and have it
detect EFI (`dmesg | grep EFI`) with this setup.

Enabling secure boot gets a bit more interesting. The [suggested](https://fedoraproject.org/wiki/Using_UEFI_with_QEMU?rd=Testing_secureboot_with_KVM)
way to enable secure boot involves downloading into a guest and running from
the EFI shell. This doesn't work with this setup because a) there is no
persistent guest state and b) the OVMF framework doesn't include a UEFI shell
by default. Fortunately, we can fix this by faking an hard drive and putting
a shell and the EFI application on it to run.

	# dd if=/dev/zero of=my_image.img bs=1M count=10
	# mkfs.fat my_image.img
	# mount -o loop my_image.img /mnt/loop_area
	# mkdir -p /mnt/loop_area/EFI/BOOT/
	# cp /usr/share/edk2.git/ovmf-x64/Shell.efi /mnt/loop_area/EFI/BOOT/bootx64.efi
	# wget http://fedorapeople.org/~crobinso/secureboot/LockDown_ms.efi -O /mnt/loop_area/
	# umount /mnt/loop_area

Add `-hda my_image.img` to your QEMU command and remove the `-kernel` and
`-initrd` options. If all goes well, you should be dropped into the UEFI
shell. You can now run the command to add keys

	Shell> FS0:
	FS0:\> LockDown_ms.efi

Your vars file should now be all set up for secure boot. If you boot with a
`-kernel` and `-initrd` option, you should be able to boot a signed kernel
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

