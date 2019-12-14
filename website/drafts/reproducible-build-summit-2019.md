title: Reproducible Builds Summit, 5th edition
date: 2019-11-12 14:00
author: Ludovic Courtès, YOUR NAME HERE!
tags: Reproducible builds
---

[For](https://guix.gnu.org/blog/2018/reproducible-builds-summit-4th-edition/)
[several](https://www.gnu.org/software/guix/blog/2015/reproducible-builds-a-means-to-an-end/)
[years](https://guix.gnu.org/blog/2016/reproducible-build-summit-2nd-edition/),
the Reproducible Builds Summit has become this pleasant and fruitful
retreat where we Guix hackers like to go and share, brainstorm, and hack
with people from free software projects and companies who share this
interest in [reproducible builds](https://reproducible-builds.org/) and
related issues.  This year, several of us had the chance to be in
Marrakesh for [the fifth Reproducible Builds
Summit](https://reproducible-builds.org/events/Marrakesh2019/), which
was attended by about thirty people.

This blog post summarizes the (subjective!) takeaways from the different
sessions we attended, and introduces some of the cool hacks that came to
life on the roof top of the lovely riad that was home to the summit.

# Java

  - F-Droid
  - Maven
  - ?

# Verifying and sharing build results

# Bootstrapping

This year the summit had an official extended format; encouraging
participants to attend for a full week by adding coding time around
the usual three more structured core days that were facilitated in a
lovely productive and high-energy fashion by Gunner an Evelyn of
[Aspiration Tech](https://aspirationtech.org).

Even before the core days started, David had packaged GNU Mes for Nix
with the aim of creating a [Reduced Binary Seed
bootstrap](https://guix.gnu.org/blog/2019/guix-reduces-bootstrap-seed-by-50/)
for NixOS.  As Vagrant
[managed](https://deb.debian.org/debian/pool/main/m/mes/mes_0.21-3_i386.deb)
to get Mes into Debian unstable before the summit, he expressed that
wanted to _do_ something with it.  We decided to attempt a
cross-distribution [Diverse Double
Compilation](https://dwheeler.com/trusting-trust/dissertation/html/wheeler-trusting-trust-ddc.html)
of Mes.  Initially, David ([Nix](https://nixos.org)), Vagrant
([Debian](https://debian.org)) and janneke ([GNU
Guix](https://guix.gnu.org)) took up the challange, soon to be joined
by Jelle ([Arch](https://archlinux.org)).  David was the first do do a
diffoscope comparison to find that Mes v0.21
[actually](http://git.savannah.gnu.org/cgit/mes.git/tree/src/mes.c?h=v0.21#n1781)
[embeds](http://git.savannah.gnu.org/cgit/mes.git/tree/configure.sh?h=v0.21#n244)
a store file name.  Always nice to see Reproducible meet
Bootstrappable ;-) Upstream was easily convinced to write a
[patch](http://git.savannah.gnu.org/cgit/mes.git/patch/?id=0549ebd0f79a7741f3f560e35171182d4afbd6b5).
More news on this real soon!

Ludovic and janneke took the opportunity to take the Guix [Scheme-only
bootstrap](http://git.savannah.gnu.org/cgit/guix.git/log/?h=wip-bootstrap)
a couple of steps further.  In a joint effort the last functional bug
was fixed and Ludovic came up with a way to avoid actually adding
[Gash](https://savannah.nongnu.org/projects/gash) and [Gash Core
Utils](https://gitlab.com/janneke/gash/tree/gash-core-utils) to the
bootstrap binary seeds.  The idea of bootstrapping from the current
%bootstrap-mes (v0.19) instead of updating to v0.21 presented itself
and was implemented by janneke right after the summit.

Andreas was wondering about the use of GCC 2.95.3 in the Guix
bootstrap and then worked to create a patch to compile gmp, mpfr, and
mpc using tinycc.  That work is helping the effort to remove the
intermediate GCC 2.95.3 from the Guix bootstrap and instead target GCC
4.6.4 directly.

All in all a very productive and especially inspiring summit for
[bootstrapping](https://bootstrappable.org) with more people and
projects on board, giving new perspectives to work on... and dream
about.

In the last _extreme bootstrapping_ work session, Hannes from
[MirageOS](https://mirage.io) was inspired to start an initial port of
Mes to FreeBSD and gave rise to...

# _Extreme_ bootstrapping!

As part of the discussions about bootstrapping, people noted that Guix’
[build
daemon](https://guix.gnu.org/manual/en/html_node/Invoking-guix_002ddaemon.html)
is usually ignored from [bootstrapping
considerations](https://guix.gnu.org/manual/devel/en/html_node/Bootstrapping.html),
and wondered whether it should be taken into account.  In effect, the
build daemon _emulates_ builds from scratch, as if one had booted into
an empty machine.  It does that by creating [isolated build
environments](https://guix.gnu.org/manual/en/html_node/Invoking-guix_002ddaemon.html)
that contain nothing but the explicitly declared inputs.  However, the
build daemon is part of the [Trusted Computing
Base](https://en.wikipedia.org/wiki/Trusted_computing_base) (TCB): like
compilers in the “trusting trust” attack, it could inject backdoors into
build results.  Thus, the question becomes: how can we reduce the TCB by
removing `guix-daemon` from it?

Vagrant Cascadian came up with this crazy-looking idea: what if we
started building things straight from [the
initrd](https://guix.gnu.org/manual/en/html_node/Initial-RAM-Disk.html)?
That way, our TCB would be stripped of `guix-daemon`, the Shepherd, and
other services running on a normal system.  Since Guix has all the build
information available in the form of
[derivations](https://guix.gnu.org/manual/devel/en/html_node/Derivations.html),
which are normally interpreted by the daemon, we found that it
_shouldn’t be that hard_ to convert them to a minimal Guile script that
would be executed during startup, from the initrd.  Some hack hours
later, we had a proof-of-concept branch, adding [a `(gnu system
bootstrap)`
module](https://git.savannah.gnu.org/cgit/guix.git/tree/gnu/system/bootstrap.scm?h=wip-system-bootstrap)
with all the necessary machinery:

  1. a function that converts an arbitrary derivation to a linear build
     script that builds all the dependency graph in topological order;
  2. the declaration of an operating system that boots into such a
     script from the initrd;
  3. a function to run [a pure-Scheme SHA256
     implementation](https://github.com/weinholt/hashing) to compute and
     display the hash of the build result.

More on that in a future post!  Interestingly, we learned that
[NBS](https://gitlab.com/giomasce/nbs) is taking a similar
approach—building from the initrd—though with different binary seeds and
specific build and packaging tooling.

We went on exploring the space of what we called “extreme bootstrapping”
some more.  How could we further reduce the TCB?  The kernel is an
obvious target: as long as we use the Linux kernel, we could disable
many optional features, even perhaps networking and storage drivers.
Fabrice Bellard’s 2004 [impressive `tcc-boot`
experiment](https://bellard.org/tcc/tccboot.html) reminds us that we
could even aim for a bootloader that builds the OS kernel before it
boots it; this removes Linux entirely from the TCB, in exchange for
[TinyCC](http://www.tinycc.org/).  As part of the “Bootstrappable
Debian” project, [`asmc`](https://gitlab.com/giomasce/asmc) takes a
similar approach: providing a very small OS kernel that’s enough to
compile simple things.  This is like going “_from inorganic matter to
organic molecules_”, [as Giovanni Mascellani nicely puts
it](https://debconf19.debconf.org/talks/152-bootstrappable-debian-bof/).

When a [Mirage](https://mirage.io/) developer and hackers familiar with
[GNU/Hurd](https://hurd.gnu.org) talk about bootstrapping, it is no
surprise that they end up looking at library OSes and microkernels.
Indeed, one could imagine booting into a dedicated Mirage unikernel
(though it would lack a POSIX personality), or booting into GNU Mach
with few or no Hurd services initially running.  That would be a way to
strip the TCB to a bare minimum…  It will be some time before we get
there, but it could well be our horizon!

# More cool hacks

  - Ten Years reproducibility challenge

During the summit, support for [_system provenance tracking_ in `guix
system`](https://issues.guix.gnu.org/issue/38441) landed in Guix.  This
allows a deployed system to embed the information needed to rebuild it:
its
[channels](https://guix.gnu.org/manual/devel/en/html_node/Channels.html)
and its [configuration
file](https://guix.gnu.org/manual/devel/en/html_node/Using-the-Configuration-System.html).
In other words, the result is what we could call a _source-carrying
system_, which could also be thought of as [a sort of
Quine](https://en.wikipedia.org/wiki/Quine_(computing)).  For users it’s
a convenient way to map a running system or virtual machine image back
to its source, or to verify that its binaries are genuine by rebuiling
it.

The [`guix
challenge`](https://guix.gnu.org/manual/devel/en/html_node/Invoking-guix-challenge.html)
command started its life [shortly before first
summit](https://guix.gnu.org/blog/2015/reproducible-builds-a-means-to-an-end/).
During this year’s hacking sessions, it [gained a `--diff`
option](https://issues.guix.gnu.org/issue/38518) that automates the
steps of downloading, decompressing, and diffing non-reproducible
archives, possibly with [Diffoscope](https://diffoscope.org/).  The idea
[came up some time ago](https://issues.guix.gnu.org/issue/35621), and
it’s good that we can cross that line from our to-do list.

# Thanks!

We are grateful to everyone who made this summit possible: Gunner and
Evelyn of Aspiration, Hannes, Holger, Lamby, Mattia, and Vagrant, as well as our
kind hosts at Priscilla.  And of course, thanks to all fellow
participants whose openmindedness and focus made this both a productive
and a pleasant experience!

#### About GNU Guix

[GNU Guix](https://www.gnu.org/software/guix) is a transactional package
manager and an advanced distribution of the GNU system that [respects
user
freedom](https://www.gnu.org/distros/free-system-distribution-guidelines.html).
Guix can be used on top of any system running the kernel Linux, or it
can be used as a standalone operating system distribution for i686,
x86_64, ARMv7, and AArch64 machines.

In addition to standard package management features, Guix supports
transactional upgrades and roll-backs, unprivileged package management,
per-user profiles, and garbage collection.  When used as a standalone
GNU/Linux distribution, Guix offers a declarative, stateless approach to
operating system configuration management.  Guix is highly customizable
and hackable through [Guile](https://www.gnu.org/software/guile)
programming interfaces and extensions to the
[Scheme](http://schemers.org) language.
