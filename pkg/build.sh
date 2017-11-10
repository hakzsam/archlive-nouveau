#!/bin/bash

pkgs=('libpciaccess-git'
      'libdrm-git'
      'xf86-video-ati-git'
      'xf86-video-intel-git'
      'xf86-video-nouveau-git'
      'llvm-svn'
      'clang-svn'
      'mesa-git'
      'envytools-git'
      'valgrind-mmt-git'
      'linux-headers-git'
      'waffle'
      'piglit-git')

asroot=""
if [ ${EUID} -eq 0 ]; then
	asroot="--asroot"
fi

for arch in "${archs[@]}"
do
	for pkg in "${pkgs[@]}"
	do
		cd $pkg
		FILES="`find ./ -name "*-${arch}.pkg.tar.xz"`"
		makepkg ${asroot}
		result=$?
		if [ ${result} -eq 0 ]; then
			rm -f ${FILES}
		elif [ ${result} -ne 1 ]; then
			echo "Failed to build '$pkg'!"
			exit 1
		fi
		cd ..
	done
done
