#!/bin/bash

archs=('x86_64')

user="${1}"
if [[ -z ${user} ]]; then
    user=${USER}
    if [[ ${EUID} -eq 0 ]]; then
        echo "Warning: You should specify a username as first argument or run \
the script as a normal user."
        echo "Some parts requires root access (like building the image and \
cleaning pacman's cache)."
        echo "If you plan to build automatically, run the script as root and \
give a normal username as first argument."
    fi
fi


# Clean local repository
cd repo && su ${USER} -c './clean.sh'
cd ..

# Clean image folder
cd iso && su -c './clean.sh'
cd ..

su -c 'pacman -Sc'


# Build custom packages.
cd pkg && su ${USER} -c "./build.sh ${archs}"
if [ $? -ne 0 ]; then
	echo "Failed to build custom packages!"
	exit 1
fi
cd ..

# Build the custom local repository.
cd repo && su ${USER} -c "./build.sh ${archs}"
if [ $? -ne 0 ]; then
	echo "Failed to build the custom local repository!"
	exit 1
fi
cd ..

# Build the latest Linux kernel and Nouveau DRM.
cd src && su ${USER} -c "./build.sh"
if [ $? -ne 0 ]; then
	echo "Failed to build the latest Linux kernel or Nouveau DRM!"
	exit 1
fi
cd ..

# Build the image.
cd iso && su -c "./build.sh -v ${archs}"
if [ $? -ne 0 ]; then
	echo "Failed to build the image!"
	exit 1
fi
cd ..

exit 0
