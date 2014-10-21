#!/bin/bash

if [ ! -d "x86_64" ]; then
	mkdir x86_64
fi

find ../pkg -name "*-x86_64.pkg.tar.xz" -exec cp {} x86_64 \;
repo-add $PWD/x86_64/custom.db.tar.gz $PWD/x86_64/*.pkg.tar.xz
