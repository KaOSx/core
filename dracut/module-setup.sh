#!/bin/bash

depends() {
    # Do not depend on any modules - just some root
    return 0
}

# called by dracut
installkernel() {
    instmods aufs
}

install() {
    inst_hook pre-pivot 10 "$moddir/aufs-mount.sh"
}
