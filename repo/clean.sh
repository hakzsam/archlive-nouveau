#!/bin/bash

if [ -d "i686" ]; then
	rm -rvf i686
fi

if [ -d "x86_64" ]; then
	rm -rvf x86_64
fi
