#!/bin/bash

# Taken from
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-which-directory-it-is-stored-in
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

linux_git=git://people.freedesktop.org/~airlied/linux
linux_dir="${dir}/linux"
linux_branch=drm-next
install_mod_path=../

force_build="${1}"

nouveau_git=git://github.com/skeggsb/nouveau
nouveau_dir="${dir}/nouveau"

# Build the latest Linux kernel.
if [ ! -d ${linux_dir} ]; then
    git clone ${linux_git} ${linux_dir} --depth 1 --branch ${linux_branch}
    if [ $? -ne 0 ]; then
        echo "Failed to update 'linux' repository!"
        exit 1
    fi
fi

# Build Nouveau DRM kernel module.
if [ -d ${nouveau_dir} ]; then
    cd ${nouveau_dir}
    git fetch origin
    res_nouveau=`git rebase origin/master`
    if [ $? -ne 0 ]; then
        git rebase --abort
        git checkout -b tmp
        git branch -D master
        git branch master origin/master
        git checkout master
        git branch -D tmp
    fi
    cd "${dir}"
else
    git clone ${nouveau_git} ${nouveau_dir} --depth 1
    if [ $? -ne 0 ]; then
        echo "Failed to clone 'nouveau' repository!"
        exit 1
    fi
fi

cd "${linux_dir}" && old_commit=`git show --no-patch --format="%H"` && cd "${dir}"
cd "${nouveau_dir}" && commit=`git log --oneline --grep="drm-next" | sed -e 's/^[a-z0-9]\{8\} drm-next //' | head -1` && cd "${dir}"

echo "\"${old_commit}\""
echo "\"${commit}\""

if [[ "${old_commit}" != "${commit}" || ! -z "${force_build}" ]]; then
    cd "${linux_dir}"
    git checkout drm-next
    res_linux=`git pull origin ${linux_branch}`
    if [ $? -ne 0 ]; then
        echo "Failed to update 'linux' repository!"
        exit 1
    fi
    git checkout ${commit}

    if [[ ! -f '.config' ]]; then
        zcat /proc/config.gz > .config
    fi
    make olddefconfig
    if [ $? -ne 0 ]; then
        echo "Failed to build old default config!"
        exit 1
    fi

    make && make modules_install INSTALL_MOD_PATH=${install_mod_path}
    if [ $? -ne 0 ]; then
        echo "Failed to build the kernel!"
        exit 1
    fi

    cd "${dir}"
fi

should_compile=`echo "${res_nouveau}" | grep "Current branch master is up to date."`
if [[ -z "${should_compile}" || "${old_commit}" != "${commit}" || ! -z "${force_build}" ]]; then
    linux_version=$(cat "${linux_dir}/include/config/kernel.release")
    linuxdir=$(echo "$PWD/lib/modules/${linux_version}/source")

    cd "${nouveau_dir}"
    cd drm && make LINUXDIR="${linuxdir}" && cd -
    if [ $? -ne 0 ]; then
        echo "Failed to build 'nouveau'!"
        exit 1
    fi
else
    echo "Nouveau: No new commits, skipping building!"
fi
