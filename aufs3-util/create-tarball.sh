#!/bin/sh
#AUFS2VERSION=""
#KERNELVERSION=2.6.35
GITSNAPSHOT=20120607
_aufsver=aufs3.0
# aufs2 (no -xx) for the latest -rc version.
rm -Rf aufs-util
git clone git://aufs.git.sourceforge.net/gitroot/aufs/aufs-util.git
cd aufs-util
#git checkout origin/aufs2${AUFS2VERSION}
git checkout origin/$_aufsver
#*** apply "aufs2-base.patch" and "aufs2-standalone.patch" to your kernel source files.
cd ..
rm -rf aufs3-util-${GITSNAPSHOT}
cp -a aufs-util aufs3-util-${GITSNAPSHOT}
tar -czf aufs3-util-${GITSNAPSHOT}.tar.gz --exclude=.git aufs3-util-${GITSNAPSHOT}
