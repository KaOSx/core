#!/bin/bash

# clone the aufs repository to the local disk
git clone http://git.c3sl.ufpr.br/pub/scm/aufs/aufs2-standalone.git aufs2-standalone.git
cd aufs2-standalone.git
git branch -r
git checkout origin/aufs2.1-39

# modify what you want

# and after
# create the patch with the directories: fs, include and Documentation

rm -v $(find . -type f -name '*.orig')
grep -qse 'EXPORT_SYMBOL(' aufs2-standalone.patch && \
sed -i-old -e 's|EXPORT_SYMBOL(|EXPORT_SYMBOL_GPL(|' aufs2-standalone.patch
rm -rf /tmp/linux-2.6
mkdir /tmp/linux-2.6
cp -a fs /tmp/linux-2.6
cp -a include /tmp/linux-2.6
cp -a Documentation /tmp/linux-2.6
echo "test"
rm /tmp/linux-2.6/include/linux/Kbuild
cd /tmp
diff -Naur null linux-2.6  | filterdiff | \
sed -e 's|null\(/include/linux/Kbuild\)|linux-2.6-old\1|;s|^--- null.*|--- /dev/null|;\|linux-2.6/include/linux/Kbuild|,${\|@@ -0,0 +1 @@|,$d}' \
| bzip2 > aufs$(sed -ne 's|#define.*AUFS_VERSION.*"\(.*\)"|\1|p'  linux-2.6/include/linux/aufs_type.h).patch.bz2
cd $OLDPWD

# the patch is created in /tmp
# the other patches needed to compile are in the base directory