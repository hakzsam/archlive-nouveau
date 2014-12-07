#!/bin/bash


archs=${1}

for arch in "${archs[@]}"
do
	if [ ! -d "${arch}" ]; then
		mkdir ${arch}
	fi

	find ../pkg -name "*-${arch}.pkg.tar.xz" -exec cp {} $arch \;
	repo-add $PWD/$arch/custom.db.tar.gz $PWD/$arch/*.pkg.tar.xz
done
