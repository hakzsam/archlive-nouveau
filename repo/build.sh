#!/bin/bash


arch='x86_64'

if [ ! -d "${arch}" ]; then
	mkdir ${arch}
fi

find ../pkg -name "*-${arch}.pkg.tar.xz" -exec cp {} $arch \;
repo-add $PWD/$arch/custom.db.tar.gz $PWD/$arch/*.pkg.tar.xz
