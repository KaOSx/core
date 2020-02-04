#!/bin/bash

rm -Rf aufs5-standalone
# clone the aufs repository to the local disk
git clone git://github.com/sfjro/aufs5-standalone.git aufs5-standalone
cd aufs5-standalone
git branch -r
git checkout origin/aufs5.5

# modify what you want

# and after
# create the patch with the directories: fs, include and Documentation

rm -v $(find . -type f -name '*.orig')
grep -qse 'EXPORT_SYMBOL(' aufs5-standalone.patch && \
sed -i-old -e 's|EXPORT_SYMBOL(|EXPORT_SYMBOL_GPL(|' aufs5-standalone.patch
rm -rf ../tmp/linux-5.5
mkdir -p ../tmp/linux-5.5
cp -a fs ../tmp/linux-5.5
cp -a include ../tmp/linux-5.5
cp -a Documentation ../tmp/linux-5.5
rm ../tmp/linux-5.5/include/uapi/linux/Kbuild
cd ../tmp
diff -Naur null linux-5.5  | filterdiff | \
sed -e 's|null\(/include/uapi/linux/Kbuild\)|linux-5.5-old\1|;s|^--- null.*|--- /dev/null|;\|linux-5.5/include/uapi/linux/Kbuild|,${\|@@ -0,0 +1 @@|,$d}' \
| bzip2 > aufs$(sed -ne 's|#define.*AUFS_VERSION.*"\(.*\)"|\1|p'  linux-5.5/include/uapi/linux/aufs_type.h).patch.bz2
mv *.bz2 $OLDPWD
cd $OLDPWD
mv *patch* ..
cd ..
rm -rf tmp aufs5-standalone


# the patch is created in ../tmp
# the other patches needed to compile are in the base directory
