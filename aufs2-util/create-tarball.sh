#!/bin/sh
#AUFS2VERSION=""
#KERNELVERSION=2.6.35
GITSNAPSHOT=20110817
# aufs2 (no -xx) for the latest -rc version.
rm -R aufs-util.git
git clone git://aufs.git.sourceforge.net/gitroot/aufs/aufs-util.git
cd aufs-util
#git checkout origin/aufs2${AUFS2VERSION}
git checkout origin/aufs2.2
#*** apply "aufs2-base.patch" and "aufs2-standalone.patch" to your kernel source files.
cd ..
rm -rf aufs2-util-${GITSNAPSHOT}
cp -a aufs-util aufs2-util-${GITSNAPSHOT}
tar -czf aufs2-util-${GITSNAPSHOT}.tar.gz --exclude=.git aufs2-util-${GITSNAPSHOT}
