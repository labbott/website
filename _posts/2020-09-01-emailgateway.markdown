---
layout: post
date: 2020/09/01 11:00:00
title: E-mail gateways and gatekeeping
category: fedora
---
So The Register managed to incite a lot of discussion with a [headline](https://www.theregister.com/2020/08/25/linux_kernel_email/)
that plain-text e-mail is a barrier to entry for kernel development. While
attention grabbing, this is actually not a new debate. Like a lot of tech
arguments this one seems to come up on a cyclical basis. Maybe because
maintainer summit didn't happen this year it needed to come out elsewhere.
I gave a few thoughts on twitter but this topic really deserves a longer
look at the problem and what e-mail being a barrier really means.

Linux celebrated over [one million commits](https://www.zdnet.com/article/commit-1-million-the-history-of-the-linux-kernel/)
recently. The Linux Foundation also came out with a report about the
[history](https://www.linuxfoundation.org/blog/2020/08/download-the-2020-linux-kernel-history-report/)
of kernel development. All of this work was completed with development being
done over e-mail. Clearly e-mail has been a successful method of development
for the past 29 years by many metrics.

So if it's so successful why consider changing? Part of the answer to this
question lies in not what was accomplished by using e-mail but what was _not_
accomplished because e-mail was the preferred method of development. I
marked 10 years of being a full-time software professional a few weeks ago.
This was a recent enough time span that I can still remember enough of what
it was like to get started. There were a lot of steps to make sure your
e-mail setup was correct (i.e. plain text and no weird footers). It was a
little tricky but certainly doable. This is where the split comes in: what's
'a little tricky' for one person may prevent someone else from contributing
at all. I was fortunate to have enough general working knowledge of Linux to
debug `git-send-email` when it didn't work as well as having a corporate
setup that could actually send plain text e-mail. Google around for how to
set up `git-send-email` and you'll see this is a step many people struggle with.

"But if you can't even set up e-mail should you really be working on the
kernel?" This is unfortunately a common refrain in this discussion. I'd
turn the question on its head: why is setting up e-mail a core skill for
working on the kernel? There's a lot of value in learning and following
community norms but what value does _that_ particular norm bring? I'd argue
that showing you can set up and use plain text e-mail does not make you
a better kernel programmer. Supporting tooling for a project is important
but there's nothing inherent to e-mail that makes it a good indicator of
anything. People can only handle keeping track of so many things at once.
Having to figure out plain text e-mail is one more task on the stack.
Reducing the overhead in mental load to participation lets people focus
much more on the actual kernel work. We can maintain tools that take less
work to run. Yes, the initial SMTP configuration is a one time setup but
sending out a patch each time with `git-send-email` involves a lot of manual
steps. Even if you get the manual steps right there's always the chance
that your e-mail will be rejected due to over zealous spam filtering. There
was a three month period or so where all my e-mails to a particular maintainer
were being rejected because my 3rd party SMTP server had ended up on a spam
blocklist.

"But you can automate e-mail to do the manual parts" To some degree yes but
this is hard to do across the entire tree. The kernel has very few unifying
standards so for those who work across multiple areas you're usually left
making a best educated guess about where things should go. MAINTAINERS is a
good start but it's not always complete. And even if you _can_ automate
everything expecting every contributor to come up with their own automation
is not a good use of time. "So provide everyone the automation" and there in
lies the problem: the fact that everyone can use their own setup is seen
as an advantage so it's impossible to give something that works for everyone.
Even trying to guess what would be the most common setup to give some baseline
hasn't been a fruitful conversation.

"So GitHub is the answer to our problems?" I'm not saying that either.
"kids these days are using GitHub so we should switch too" is a very weak
argument. Familiarity with a tool is a factor but it shouldn't be the biggest
factor. Everyone, new and experienced developers, can learn new tools. If I
thought that e-mail was a suitable tool I would be promoting it as something
newer developers should learn. Compare that with git which both new and
experienced people will tell you can be difficult to use. It _is_ worthwhile
to learn git though and there's been some improvement in UX recently
(`git switch`). One objection to GitHub is the fact that it's a proprietary
platform. I'm not willing to entertain conspiracy theories about GitHub
being owned by Microsoft and therefore wanting to destroy the Linux kernel
but before committing to any cloud platform it's important to do due diligence.
Part of the concern about the 'forge' nature of GitHub is that it ends
up being an single point of failure. Anyone who has tried to get work done
when its down will know what a pain this is. The issue is that despite the
fact that git is a distributed version control system you end up needing
to host your repositories _somewhere_ for pull requests to be useful. Anything
that's useful is going to end up being popular so you're going to end up
with more points of failure. "What if we all just hosted our own git trees"
running infrastructure takes time, energy, and money, it's really nice to
not have to think about things like that.

"But e-mail is so much better for discussion and patch review" it's hard
to differentiate sometimes between "better because I'm more familiar with it"
and "better because it has features I care about". Is the experience of
reviewing code in GitHub identical to reviewing code in e-mail? No. The
steps are different. It's never going to match 1-to-1. Do I think code
review in GitHub is usable? Absolutely. Would I take GitHub review over
e-mail? Unclear mostly because it's hard for me to separate everything else
I hate about e-mail patches from the review part. One nice advantage of
GitHub is that it is incredibly easy to jump in on threads without having
subscribed to the thread first. [lore.kernel.org](https://lore.kernel.org/lists.html)
has improved the experience of replying via e-mail significantly by providing
instructions and download links but it's not as easy as point and click.
lore.kernel.org has also improved the archiving experience significantly
which was another area of concern with e-mail. Even with a proper archiving
system, discussion is still disconnected from both bug reporting and the
code review with e-mail. E-mail is really a lousy bug reporting system
simply because it's easy for things to get lost. "You can filter e-mail"
yes, if you know what to filter on. Again, everyone having bespoke artisinal
e-mail filters doesn't actually solve the problem. Having a distinct
separation between bug reports and new code is much easier to keep straight.
I also grow weary of having to explain to new contributors that LKML is
mostly just an archive and sending anything to LKML without another cc is
probably not going to get a response (a great way to discourage contributors).
Again, there is documentation out there to explain how to contribute but it
doesn't actually _need_ to be this complicated.

"GitHub could never scale to the volume of the Linux Kernel" This is an
interesting point. There was some discussion on twitter about monorepos.
The kernel does appear to be unique in terms of number of contributors and
volume of commits. Maybe GitHub can't actually scale. That shouldn't mean
the only option ever is e-mail. Git itself came out of a need for a version
control system that matched what the kernel needed (we'll ignore other
parts of the [BitKeeper](https://en.wikipedia.org/wiki/BitKeeper) saga).
The scaling issue often comes up when discussing CI. Those outside the
kernel community are somewhat shocked and appalled about how much manual
work happens. [KernelCI](https://staging.kernelci.org/) has come a long
way in integrating CI as part of the regular development process. It's not
clear if a traditional CI system like GitHub offers would even make sense.
For one, testing kernels requires either physical machines to test on or
a virtual environment, neither of which are particularly standard for setups
like GitHub. The kernel is also (intentionally) designed to work on an
incredibly wide variety of hardware. Testing every commit against all
possible hardware is next to impossible. Even choosing a limited set of hardware
can quickly create a bottleneck for getting anything merged. KernelCI has
done a great job trying to balance coverage and speed. Part of the issue
with the scaling argument is that it's a bit of chicken and egg to determine
if something like GitHub would actually scale. We can't switch over because
we are concerned it might not scale but we can't really know if it scales
until we switch over. The kernel likes small incremental changes but switching
development workflows may be impossible to do incrementally.

Plain text e-mail may not be the biggest barrier for many people wanting
to do kernel development but it can still be one. There are plenty of reasons
to want something better than e-mail for development. There may be some
reasons to stay on e-mail because no better tool exists but "lowering the
bar" or other gatekeeping nonsense is not among the reasons. I personally
eagerly await the day I don't have to think about e-mailing patches. 
