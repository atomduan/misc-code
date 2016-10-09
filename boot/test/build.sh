#!/bin/bash -
rm boot.img boot.bin
dd if=/dev/zero of=boot.img bs=1024 count=1
nasm boot.s -o boot.bin
dd if=boot.bin of=boot.img
