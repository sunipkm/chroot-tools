#!/bin/bash
declare -a basedirs=("bin" "etc" "sbin" "lib" "proc" "sys" "dev")
if [[ -d "$1" ]]; then
    echo "Preparing to chroot into $1"
    echo "Checking if it is a base linux fs"
    for basedir in ${basedirs[@]}; do
        if ! [[ -d "$1/$basedir" ]]; then
            echo "$1/$basedir not found, not a chroot base dir"
            exit 2
        fi 
    done
    # Copy qemu-arm-static
    cp `which qemu-arm-static` $1/usr/bin/
    # Mount proc, sys, dev
    mount -t proc proc $1/proc
    mount --bind /dev $1/dev
    mount --bind /sys $1/sys
    # Copy resolv.conf
    cp /etc/resolv.conf $1/etc/resolv.conf
    # We have finished chrooting
    echo "chroot env set up. Run chroot-exit.sh in this terminal to automatically clean up"
    export CHROOT_ARM_SETUP
    chroot $1 qemu-arm-static /bin/bash
    
    # clean up
    rm $1/etc/resolv.conf
    rm $1/usr/bin/qemu-arm-static
    # unmount
    umount $1/proc
    umount $1/sys
    umount $1/dev
    # exit
    sync
    echo "Cleaned up $1, safe to unmount"
    unset -v CHROOT_ARM_SETUP
    exit 0
else
    echo "$1 is not a valid directory, can not chroot"
fi
