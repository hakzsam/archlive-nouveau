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
    cd ${linux_dir}
    res=`git pull origin ${linux_branch}`
    cd -
fi
if [ $? -ne 0 ]; then
    echo "Failed to update 'linux' repository!"
    exit 1
fi

should_compile=`echo "${res}" | grep "Already up-to-date"`
if [[ -z "${should_compile}" ]]; then
    cd ${linux_dir}
    if [[ ! -f '.config' ]]; then
        zcat /proc/config.gz > .config
    fi
    make olddefconfig
    if [ $? -ne 0 ]; then
        echo "Failed to build old default config!"
        exit 1
    fi

    make && make modules_install INSTALL_MOD_PATH=${install_mod_path} && cd -
    if [ $? -ne 0 ]; then
        echo "Failed to build the kernel!"
        exit 1
    fi
else
    echo "Linux: No new commits, skipping building!"
fi

# Build Nouveau DRM kernel module.
if [ -d ${nouveau_dir} ]; then
    cd ${nouveau_dir}
    git fetch origin
    res=`git rebase origin/master`
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

should_compile=`echo "${res}" | grep "Current branch master is up to date."`
if [[ -z "${should_compile}" ]]; then
    linux_version=$(cat ${linux_dir}/include/config/kernel.release)
    linuxdir=$(echo "$PWD/lib/modules/${linux_version}/source")

    cd ${nouveau_dir}
    make && cd drm && make LINUXDIR=${linuxdir} && cd -
    if [ $? -ne 0 ]; then
        echo "Failed to build 'nouveau'!"
        exit 1
else
    echo "Nouveau: No new commits, skipping building!"
    fi
fi
