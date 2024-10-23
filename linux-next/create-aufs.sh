#!/bin/bash

rm -Rf aufs-standalone
# clone the aufs repository to the local disk
git clone https://github.com/sfjro/aufs-standalone.git aufs6-standalone
cd aufs6-standalone
git branch -r
git checkout origin/aufs6.11

# modify what you want

# and after
# create the patch with the directories: fs, include and Documentation

rm -v $(find . -type f -name '*.orig')
grep -qse 'EXPORT_SYMBOL(' aufs6-standalone.patch && \
sed -i-old -e 's|EXPORT_SYMBOL(|EXPORT_SYMBOL_GPL(|' aufs6-standalone.patch
rm -rf ../tmp/linux-6.11
mkdir -p ../tmp/linux-6.11
cp -a fs ../tmp/linux-6.11
cp -a include ../tmp/linux-6.11
cp -a Documentation ../tmp/linux-6.11
rm ../tmp/linux-6.11/include/uapi/linux/Kbuild
cd ../tmp
diff -Naur null linux-6.11  | filterdiff | \
sed -e 's|null\(/include/uapi/linux/Kbuild\)|linux-6.11-old\1|;s|^--- null.*|--- /dev/null|;\|linux-6.11/include/uapi/linux/Kbuild|,${\|@@ -0,0 +1 @@|,$d}' \
| bzip2 > aufs$(sed -ne 's|#define.*AUFS_VERSION.*"\(.*\)"|\1|p'  linux-6.11/include/uapi/linux/aufs_type.h).patch.bz2
mv *.bz2 $OLDPWD
cd $OLDPWD
mv *patch* ..
cd ..
#rm -rf tmp aufs5-standalone


# the patch is created in ../tmp
# the other patches needed to compile are in the base directory
