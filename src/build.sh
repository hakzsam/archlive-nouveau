#!/bin/bash

linux_git=git://people.freedesktop.org/~airlied/linux
linux_dir=linux
linux_branch=drm-next
install_mod_path=../

nouveau_git=git://people.freedesktop.org/~darktama/nouveau
nouveau_dir=nouveau

# Build the latest Linux kernel.
if [ ! -d ${linux_dir} ]; then
    git clone ${linux_git} ${linux_dir} --depth 1 --branch ${linux_branch}
else
    cd ${linux_dir} && git pull origin ${linux_branch} && cd -
fi
if [ $? -ne 0 ]; then
    echo "Failed to update 'linux' repository!"
    exit 1
fi

cd ${linux_dir}
zcat /proc/config.gz > .config && make olddefconfig
if [ $? -ne 0 ]; then
    echo "Failed to build old default config!"
    exit 1
fi

make && make modules_install INSTALL_MOD_PATH=${install_mod_path} && cd -
if [ $? -ne 0 ]; then
    echo "Failed to build the kernel!"
    exit 1
fi

# Build Nouveau DRM kernel module.
if [ -d ${nouveau_dir} ]; then
    cd ${nouveau_dir}
    git fetch origin && git rebase origin/master
    if [ $? -ne 0 ]; then
        echo "Failed to update 'nouveau' repository!"
        exit 1
    fi
    cd ../
else
    git clone ${nouveau_git} ${nouveau_dir} --depth 1
    if [ $? -ne 0 ]; then
        echo "Failed to clone 'nouveau' repository!"
        exit 1
    fi
fi

linux_version=$(cat ${linux_dir}/include/config/kernel.release)
linuxdir=$(echo "$PWD/lib/modules/${linux_version}/source")

cd ${nouveau_dir}
./autogen.sh && make && cd drm && make LINUXDIR=${linuxdir} && cd -
if [ $? -ne 0 ]; then
    echo "Failed to build 'nouveau'!"
    exit 1
fi
