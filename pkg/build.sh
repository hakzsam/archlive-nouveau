#!/bin/bash

archs=${1}

i686chroot="$PWD/../"

pkgs=('libpciaccess-git'
      'libdrm-git'
      'xf86-video-ati-git'
      'xf86-video-intel-git'
      'xf86-video-nouveau-git'
      'mesa-git'
      'envytools-git'
      'valgrind-mmt-git'
      'piglit-git')

asroot=""
if [ ${EUID} -eq 0 ]; then
	asroot="--asroot"
fi

for arch in "${archs[@]}"
do
	if [ ${arch} == x86_64 ]; then
		cmd="makepkg ${asroot} -f"
	elif [ ${arch} == i686 ]; then
		cmd="extra-i686-build -r ${i686chroot}"
	fi

	for pkg in "${pkgs[@]}"
	do
		cd $pkg && ${cmd} && cd ..
		if [ $? -ne 0 ]; then
			echo "Failed to build '$pkg' for '$arch'!"
			exit 1
		fi
	done
done
