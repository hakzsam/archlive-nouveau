#!/bin/bash

# Build custom packages.
cd pkg && ./build.sh && cd -
if [ $? != 0 ]; then
	echo "Failed to build custom packages!"
	exit 1
fi

# Build the custom local repository.
cd repo && ./build.sh && cd -
if [ $? != 0 ]; then
	echo "Failed to build the custom local repository!"
	exit 1
fi

# Build the latest Linux kernel and Nouveau DRM.
cd src && ./build.sh && cd -
if [ $? != 0 ]; then
	echo "Failed to build the latest Linux kernel or Nouveau DRM!"
	exit 1
fi

# Build the image.
cd iso && ./build.sh -v && cd -
if [ $? != 0 ]; then
	echo "Failed to build the image!"
	exit 1
fi

exit 0
