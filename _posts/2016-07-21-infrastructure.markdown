---
layout: post
date: 2016/07/21 11:00:00
title: Open Source Infrastructure and the kernel
category: fedora, hottakes
---
(Given I'm talking about the kernel ecosystem and corporations, this is a
reminder that these thoughts are my own)

[Nadia Eghbal](https://twitter.com/nayafia) recently published an excellent
[report](http://www.fordfoundation.org/library/reports-and-studies/roads-and-bridges-the-unseen-labor-behind-our-digital-infrastructure)
about funding and maintaining open source infrastructure. It's long but very
easy to read. There's a nice [series of selections](https://storify.com/Lukasaoz/open-source-infrastructure-white-paper)
available if you don't have time to read all of it (but I recommend you do!).
The basic premise of the paper is that many key open source projects are under
funded and maintained. It's easy to have projects fall through the cracks.
Most of the focus was on various userspace projects. The kernel was briefly
mentioned as a success story. Comparatively speaking, the kernel _is_ well
funded and maintained. I'm going to expand on some of the good things and
bad things about infrastructure and the kernel ecosystem.

[LWN](http://www.lwn.net)[^1] always puts out a report for each development
cycle about who contributes to the kernel. The results are
[pretty stable](http://lwn.net/Articles/686697/) at this point. Employees of
companies are doing most of the contributions to the kernel. This is a good
thing. Companies see the value in Linux and want to pay people to make it
better. They don't do this out of some altruistic love for
software though (at least not most of them). These corporations have a product
they are trying to deliver and paying people to deliver code to the upstream
community is part of their strategy. The important point is 'strategy'. The
terrible secret of space: most kernel developers are going to be advocating
for something their employer wants. This is (usually) not some gigantic
conspiracy that ruins everything. Most kernel developers who regularly work
with the community are smart enough to not advocate for bad ideas just because
an employer wants them. Advocating for garbage is a great way to get people to
stop paying attention to you, which defeats the point of working with the
community.

Where the kernel is unique (and why it succeeds) is the number of employers
willing to sponsor maintainers and not just developers. Kernel maintainers
are highly valued; LinuxCon this year is having [office hours](http://events.linuxfoundation.org/events/linuxcon-north-america/extend-the-experience/meet-maintainers-ask-experts)
with kernel maintainers. Employers love being able to say "we employ kernel
maintainers of X". It helps to build a reputation as a company where other
kernel developers want to be. Employers sometimes think that having maintainers
on staff will give them an advantage; "Oh boy, they can review my code before
it goes out". This may not be true: most maintainers will advocate for review
and discussion of all patches in public. Companies often get the advantage of
being forced to follow best community practices when they hire maintainers,
which may not be the advantage they expected or wanted. It makes them better
open source contributors though.

The Linux kernel is an old project compared to most of the projects
discussed in the report. The maintainers and developers have spent years
figuring out what actually works for successful support. Groups like the
[Linux Foundation](https://www.linux.com/blog/how-microchip-got-their-driver-kernel-mainline), [Linaro](http://www.linaro.org) and
[smaller](http://free-electrons.com/) [consulting](http://otter.technology/)
[companies](http://baylibre.com/) are designed to help companies with their
contributions and become good open source participants. This is step
\#0 to getting sustainable open source: companies have to understand how to
participate in the community and feel like they are part of the community.
They will not see the value in funding if they aren't participating. Worse,
they lose perspective on why funding maintainers is important (It's about
supporting community, not having leverage to tell someone what to do).

The funding and corporate hand
holding of organizations like The Linux Foundations can raise
[questions](https://lwn.net/Articles/672637/) about
neutrality. Is the kernel becoming 'pay to play' where unless you are a
company with money to throw at the Linux Foundation you won't get to have
a say? I don't believe so. I think the kernel community will always be a
community at heart, independent of any company. There are enough good people
involved to keep things going in the right direction. That said, pretending
that corporations are always going to act altruistically is naive. Capitalism
is harsh and throwing money around is a good way to make things happen. My
plan personally is to stay informed and be an active participant in the
kernel community.

This leads into one of the big disadvantages of this setup: the growth of
companies participating in the kernel makes it much harder for general community
members to find a role. Recruiting new people is something that gets discussed
in the kernel community as an open problem. Just coming in and saying "I'm new
here, I want to do kernel development" doesn't often lead to long term
contributors. The kernel community has gotten very good at helping people get
their first patch accepted. The staging tree is full of drivers that needs
easy fixups so first time contributors can practice their patch skills. Mos
people struggle to figure out what to do after that first patch though. There
is a huge gap between fixing style errors and making a more significant
contribution. Most community members don't have the time to
do significant mentoring of projects outside of [structured programs](https://wiki.gnome.org/Outreachy).
Companies have the advantage of having a nearly endless supply work and
more experienced individuals readily available to help newcomers. It isn't
always perfect but it's a much better starting point. Other people in the
company can also help provide introductions and connections to get involved
with projects. Is it impossible to do kernel development without full time
employment? No, but it's much easier. Once you've gotten name recognition in
the community it's much easier to work outside of a company. This is incredibly
unfortunate for diversity efforts. The most under represented
groups in open source are also the least likely to be employed by software
companies. What you end up with is a community that's difficult to break
into and fairly homogeneous. I'd love to see this change but there's no
easy solution, partially because shouting "it's not a pipeline problem"
hasn't gotten through yet. ([It isn't a pipeline problem](https://www.google.com/#q=it%27s+not+a+pipeline+problem).
It just isn't.)

The kernel provides some great examples to those looking to expand their
infrastructure. Hopefully others can learn from the weaknesses as well.

[^1]: While we're talking about infrastructure, LWN is an excellent place to
put your money. The reporting is top notch. Please subscribe and support.
