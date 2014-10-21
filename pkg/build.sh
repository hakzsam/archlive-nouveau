#!/bin/bash

pkgs=('libpciaccess-git'
      'libdrm-git'
      'xf86-video-nouveau-git'
      'mesa-git'
      'envytools-git'
      'valgrind-mmt-git')

asroot=""
if [ ${EUID} == 0 ]; then
    asroot="--asroot"
fi

for pkg in "${pkgs[@]}"
do
	cd $pkg && makepkg ${asroot} -f && cd ..
	if [ $? != 0 ]; then
		echo "Failed to build '$pkg'!"
		exit 1
	fi
done
