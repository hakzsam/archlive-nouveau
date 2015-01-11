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
      'waffle'
      'piglit-git')

asroot=""
if [ ${EUID} -eq 0 ]; then
	asroot="--asroot"
fi

for arch in "${archs[@]}"
do
	if [ "${arch}" == 'x86_64' ]; then
		cmd="makepkg ${asroot}"
	elif [ "${arch}" == 'i686' ]; then
		cmd="extra-i686-build -r ${i686chroot}"
	fi

	for pkg in "${pkgs[@]}"
	do
		cd $pkg
		FILES="`find ./ -name "*-${arch}.pkg.tar.xz"`"
		${cmd}
		if [ $? -eq 0 ]; then
			rm -f ${FILES}
		elif [ $? -ne 1 ]; then
			echo "Failed to build '$pkg' for '$arch'!"
			exit 1
		fi
		cd ..
	done
done
