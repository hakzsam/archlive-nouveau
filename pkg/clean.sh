#!/bin/bash

find . -name "*.pkg.tar.xz" -exec rm -vf {} \;
rm -rf valgrind-mmt-git/src/valgrind/VEX
