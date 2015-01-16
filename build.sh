#!/bin/bash

archs=('x86_64')


cd repo && ./clean.sh && cd ..
cd iso && ./clean.sh && cd ..

pacman -Sc


# Build custom packages.
cd pkg && ./build.sh ${archs} && cd -
if [ $? -ne 0 ]; then
	echo "Failed to build custom packages!"
	exit 1
fi

# Build the custom local repository.
cd repo && ./build.sh ${archs} && cd -
if [ $? -ne 0 ]; then
	echo "Failed to build the custom local repository!"
	exit 1
fi

# Build the latest Linux kernel and Nouveau DRM.
cd src && ./build.sh && cd -
if [ $? -ne 0 ]; then
	echo "Failed to build the latest Linux kernel or Nouveau DRM!"
	exit 1
fi

# Build the image.
cd iso && ./build.sh -v ${archs} && cd -
if [ $? -ne 0 ]; then
	echo "Failed to build the image!"
	exit 1
fi

exit 0
