---
layout: post
date: 2016/05/16 16:00:00
title: Packaging the bisect scripts
category: fedora
permalink: /blog/2016/05/16/packaging-the-bisect-scripts/
---
One of the goals of the bisect scripts was to lower the effort for non-kernel
developers to bisect the kernel. When the scripts are used on the right
problem, they do this very well. One of the common complaints though is that
the dependencies need to be installed manually and there's still a curve for
getting started.

In the interest of making things easier, I did some work to improve the
packaging of fedbisect:

- It now has packaging at all. I put this as point 0 because there is a big
gap between hacking some scripts that work for me and having those scripts as
an actual project. The previous release was mostly just whatever I threw
together.

- It now has an explicit license. [This one really should have been there from
the beginning](http://www.techrepublic.com/article/the-github-kids-still-dont-care-about-open-source/).

- The project now looks a little bit more like a python project. It has a
setup.py and can be installed using standard python methods.

- The location of the working directory is no longer limited to be within the
fedbisect project, it can be placed anywhere with the caveat that ~15G worth
of build space is required. (Fun fact: My /tmp is not big enough to hold a
build. Thunderbird can't send e-mail if /tmp is full. bash completion doesn't
work either.)

- There is now a separate [repo](https://pagure.io/fedbisect-rpm) for hosting
a .spec file to package as an RPM. This specifies the build requirements and
also the install requirements. This should reduce runtime issues caused by
lack of packages.

- I set up a [COPR](https://copr.fedorainfracloud.org/coprs/labbott/fedbisect/)
to install RPMs of releases. The initial test was just rawhide but I plan to
have builds for most stable releases.

The packaging still isn't perfect; each release still requires manual steps
from me. I will certainly look at pull requests for improvements.

I also experimented with putting the scripts in a Docker container to (maybe)
reduce the overhead even more. This worked great for installing but I ran
out of space in the container when trying to do a kernel build. This seems like
something that will be doable in a [later](https://github.com/docker/docker/pull/14709)
Docker release though.
