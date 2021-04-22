---
layout: post
date: 2021/04/21 11:00:00
title: Untrustworthy research methods
category: fedora
---
[edit 4/22: Initial [review](https://lore.kernel.org/lkml/202104221451.292A6ED4@keescook/)
has found good faith patches from UMN.]

(As a general reminder I speak only for myself here)

So by now many people have seen the [report](https://twitter.com/gregkh/status/1384785747874656257)
that researchers from the University of Minnesota have a [paper](https://github.com/QiushiWu/QiushiWu.github.io/blob/main/papers/OpenSourceInsecurity.pdf)
about trying to introduce bugs in the Linux kernel by submitting malicious
patches. The goal was to demonstrate how likely it was for an attacker to be
able to introduce bugs without maintainers noticing. At a high level this is
a pertinent question that the kernel community has been asking itself for some
time. "Linus' law" about code review finding bugs has been repeated ad nauseam.
The issue for many [subsystems](https://lwn.net/Articles/718212/) is figuring
out how to scale that review.

The problem with the approach the authors took is that it doesn't actually
show anything particularly new. The kernel community has been well aware of this
gap for a while. Nobody needs to actually intentionally put bugs in the
kernel, we're perfectly capable of doing it as part of our normal work flow.
I, personally, have introduced bugs like the ones the researchers introduced,
not because I want to bring the kernel down from the inside but because I
am not infallible.
The actual work that needs to be done is figuring out how to continue to
scale efforts like [KernelCI](https://kernelci.org/) to fully test and find
issues before they get committed.

"But isn't this a supply chain attack" Yes, again, this is a possible attack
vector but it's one the kernel community is well aware of. Actually turning
this into an attack would probably involve getting multiple coordinating
patches accepted and then waiting for them to show up in distributions.
That's potentially a multi-year time frame depending on the distribution in
question. This also assumes that the bug(s) won't be found and fixed in the
mean time. One of the patches submitted by the researchers was [cited](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit?id=b9ad3e9f5a7a760ab068e33e1f18d240ba32ce92)
as being fixed after fuzzing with syzkaller. I don't know for certain if the
[original patch](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit?id=a068aab42258)
was one of the intentionally buggy patches but the point is there's no
guarantee that code you submit is going to stay in the form you want. You'd
really have to be in it for the long haul to make an attack like this work.
I'm certain there are actors out there who _would_ be able to pull this off
but the best fix here is to increase testing and bug fixing, something
Greg has been [requesting](https://lore.kernel.org/linux-doc/YH5tAqLr965MNZyW@kroah.com/)
for a long time. (I have other thoughts about the Rust specific bits but the
letting people work on bugs part is solid).

Greg has posted a [revert](https://lore.kernel.org/lkml/20210421130105.1226686-1-gregkh@linuxfoundation.org/)
of a bunch of the patches from the researchers. A more interesting question
to look at is the trust relationship involved in those commits. Most kernel
patches do not get sent to Linus directly. They end up getting pulled in
through one or more maintainer trees before ending up in Linus' master branch.
Many of the researcher patches were for drivers. It's fairly common for a
maintainer of a subsystem (say sound or video) to not actually have hardware
for every driver in the tree. They rely on specific driver maintainers to do
the review and testing when they can. How much review a subsystem maintainer
does ends up coming down to trust. If driver maintainer is submitting
consistently good patches, they may be trusted to submit their patches with
less review. Conversely, a driver that is consistently buggy will probably
get more scrutiny from a maintainer. Smaller patches probably aren't going to
get examined by either Linus or Greg unless they have been explicitly flagged
by a subsystem maintainers.

Picking a somewhat obscure driver could seem like a good way to introduce an
attack vector since there could potentially
be less people interested reviewing the code in detail. The flip side of this
is that your attack vector may not actually be widely used enough
because it is obscure (unless you know your target say specifically uses ISDN
or a particular media driver). There's also no guarantee that your obscure
driver would actually use the in tree driver. Many embedded platforms have a
long history of using out of tree drivers despite having ones available
upstream.

[edit 4/22: Brad Spengler pointed out that the malicious patches were
submitted with random g-mail addresses, not a known trusted e-mail address.
This is my mistake. I reworked the following paragraph with that in mind.]
The researchers themselves had submitted a number of patches to the kernel
under their own names but submitted the malicious patches under random
g-mail addresses. This is a pretty poor attack vector since, again, to do
something effective you would probably need multiple small patches.
You'd have to be very good at what you are doing to not raise suspicion.
The minute someone starts pushing a _little_ too much to take a patch or
make a change people are going to start asking question. Trust is easily
broken and hard to build up. This is why all the patches from the researchers
are considered tainted at this point even if they claim they were submitted
in good faith. This is what happens when major bugs are found in the kernel.
Patches are reverted and then heavily scrutinized before anything is let back
in. It would have been helpful to have a clear list of all patches submitted
with a note of which ones were actually bad (at this point everyone seems to be
playing guess the bad patch).

The researchers attempted to [clarify](https://www-users.cs.umn.edu/~kjlu/papers/clarifications-hc.pdf)
some of their work. The way this is written really gives me pause if the
researchers understand what happened here. It states "...its goal is to call for
efforts to improve the patching process --- to motivate more work that develops
techniques to test and verify patches, and finally to make OSS safer."
If the researchers had actually focused on testing and verifying patches we
would not be having this conversation. The authors stated "We
did not introduce or intend to introduce any bug or vulnerability in the
Linux kernel." Saying they did not introduce a vulnerability among any of
the patches they submitted is a pretty strong statement. Non-malicious patches
are still the most common way bugs are introduced and at least [some](https://lore.kernel.org/lkml/nycvar.YFH.7.76.2104211628560.18270@cbobk.fhfr.pm/)
of the presumably good patches were still flagged by maintainers. The list of
suggested fixes includes "OSS projects would be suggested to update the code of
conduct, something like “By submitting the patch, I agree to not intend to
introduce bugs”." This would stop good intentioned but ill-advised academic
researchers but actual bad actors who have the time and motivation to
do such an attack will not actually care about the code of conduct.
This entire thing comes across as not fully understanding the Linux kernel
community or how it works. 

For anyone who actually cares about the security and stability of any open
source project, take the time to ask maintainers what kind of help they
actually want and need. Maybe it's bug fixing but maybe it's triage or
documentation. Assuming that you already know what kind of problems a
community faces or simply want to highlight things in the name of "awareness"
is a recipe for disaster.
