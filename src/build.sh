#!/bin/bash

linux_git=git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
linux_dir=linux
install_mod_path=../

nouveau_git=git://people.freedesktop.org/~darktama/nouveau
nouveau_dir=nouveau

# Build the latest Linux kernel.
if [ ! -d ${linux_dir} ]; then
    git clone ${linux_git} ${linux_dir} --depth 1
else
    cd ${linux_dir} && git fetch origin && git rebase origin && cd -
fi
if [ $? != 0 ]; then
    echo "Failed to update 'linux' repository!"
    exit 1
fi

cd ${linux_dir}
zcat /proc/config.gz > .config && make olddefconfig
if [ $? != 0 ]; then
    echo "Failed to build old default config!"
    exit 1
fi

make && make modules_install INSTALL_MOD_PATH=${install_mod_path} && cd -
if [ $? != 0 ]; then
    echo "Failed to build the kernel!"
    exit 1
fi

# Build Nouveau DRM kernel module.
if [ ! -d ${nouveau_dir} ]; then
    git clone ${nouveau_git} ${nouveau_dir} --depth 1
else
    cd ${nouveau_dir} && git fetch origin && git rebase origin && cd -
fi
if [ $? != 0 ]; then
    echo "Failed to update 'nouveau' repository!"
    exit 1
fi

linux_version=$(cat ${linux_dir}/include/config/kernel.release)
linuxdir=$(echo "$PWD/lib/modules/${linux_version}/source")

cd ${nouveau_dir}
./autogen.sh && make && cd drm && make LINUXDIR=${linuxdir} && cd -
if [ $? != 0 ]; then
    echo "Failed to build 'nouveau'!"
    exit 1
fi
