#!/bin/bash

archs=('x86_64')


# Clean local repository
cd repo && ./clean.sh
cd ..

# Clean image folder
cd iso && ./clean.sh
cd ..

pacman -Sc


# Build custom packages.
cd pkg && ./build.sh ${archs}
if [ $? -ne 0 ]; then
	echo "Failed to build custom packages!"
	exit 1
fi
cd ..

# Build the custom local repository.
cd repo && ./build.sh ${archs}
if [ $? -ne 0 ]; then
	echo "Failed to build the custom local repository!"
	exit 1
fi
cd ..

# Build the latest Linux kernel and Nouveau DRM.
cd src && ./build.sh
if [ $? -ne 0 ]; then
	echo "Failed to build the latest Linux kernel or Nouveau DRM!"
	exit 1
fi
cd ..

# Build the image.
cd iso && ./build.sh -v ${archs}
if [ $? -ne 0 ]; then
	echo "Failed to build the image!"
	exit 1
fi
cd ..

exit 0
