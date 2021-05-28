#!/usr/bin/env bash
# This script creates and activates a container when run as root.
# The file names used are from Ubuntu 18.04.
# https://medium.com/@saschagrunert/demystifying-containers-part-i-kernel-space-2c53d6979504

# Create the filesystem.
# It will only contain bash, ls, and the libraries to run them.
mkdir -p container-demo/{bin,lib,lib64,sys}

# Mount /sys into the filesystem to control cgroups.
mount --rbind /sys container-demo/sys
mount --make-rslave container-demo/sys

# Copy the binaries.
cp -a /bin/{bash,ls} container-demo/bin

# Copy the libraries used by bash.
# These are retrieved with `ldd /bin/bash`.
cp -a /lib/x86_64-linux-gnu/{libtinfo.so.5,libdl.so.2,libc.so.6,ld-2.27.so} \
    container-demo/lib

# Copy the additional libraries used by ls.
# These are retrieved with `ldd /bin/ls`.
cp -a /lib/x86_64-linux-gnu/{libselinux.so.1,libpcre.so.3,libpthread.so.0} \
    container-demo/lib

# Copy all linked libraries. TODO djt, has some problem?
for x in container-demo/lib
do
    cp -a /lib/x86_64-linux-gnu/$(readlink $x) container-demo/lib
done

# Fix the linker symlink.
ln -s /lib/x86_64-linux-gnu/ld-2.27.so container-demo/lib64/ld-linux-x86-64.so.2

# Create a new cgroup to limit CPU to 10%.
# See: `man cgroups` for more information.
mkdir -p /sys/fs/cgroup/cpu/container-demo

# Limit the amount of CPU the process can use to 10%.
# CPU percentage is a ratio of the following values (in microseconds):
# {cfs_quota_us}/{cfs_period_us} * 100%
# 100000 / 1000000 * 100% = 10%
echo 1000000 > /sys/fs/cgroup/cpu/container-demo/cpu.cfs_period_us
echo 100000 > /sys/fs/cgroup/cpu/container-demo/cpu.cfs_quota_us

# Create a new cgroup to limit memory to 1 GB.
# See: `man cgroups` for more information.
mkdir -p /sys/fs/cgroup/memory/container-demo

# Limit the amount of memory the process can use to 1 GB.
echo 1G > /sys/fs/cgroup/memory/container-demo/memory.limit_in_bytes

# Create a new namespace that separates new processes from the root system.
# Using --fork runs the command as the root process in the namespace.
# See: `man namespaces` for more information.
unshare --fork --pid --mount-proc chroot container-demo /bin/bash -c "
# Add the root process of the namespace (PID=1) to the cpu:container-demo cgroup.
echo 1 > /sys/fs/cgroup/cpu/container-demo/cgroup.procs

# Add the root process of the namespace (PID=1) to the memory:container-demo cgroup.
echo 1 > /sys/fs/cgroup/memory/container-demo/cgroup.procs

# Open the shell in the chroot.
bash
"

# Clean up the container.
umount -R container-demo/sys
rm -fr container-demo
