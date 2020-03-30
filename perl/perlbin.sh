# Set path to perl scriptdirs if they exist
# Added /usr/bin/*_perl dirs for scripts

[ -d /usr/bin/site_perl ] && PATH=$PATH:/usr/bin/site_perl

[ -d /usr/bin/vendor_perl ] && PATH=$PATH:/usr/bin/vendor_perl

[ -d /usr/bin/core_perl ] && PATH=$PATH:/usr/bin/core_perl

export PATH

# If you have modules in non-standard directories you can add them here.
#export PERLLIB=dir1:dir2

