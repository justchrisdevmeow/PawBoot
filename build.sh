#!/bin/bash

nasm -f bin stage1.asm -o stage1.bin
nasm -f bin stage15.asm -o stage15.bin
nasm -f bin pawboot.sys -o pawboot.sys

dd if=/dev/zero of=pawboot.img bs=512 count=2880
dd if=stage1.bin of=pawboot.img conv=notrunc bs=512 count=1 seek=0
dd if=stage15.bin of=pawboot.img conv=notrunc bs=512 count=8 seek=1
dd if=pawboot.sys of=pawboot.img conv=notrunc bs=512 count=16 seek=9

mkfs.fat -F 12 -C pawboot.img 2880
dd if=stage1.bin of=pawboot.img conv=notrunc bs=512 count=1 seek=0
dd if=stage15.bin of=pawboot.img conv=notrunc bs=512 count=8 seek=1

mkdir -p mnt
sudo mount -o loop pawboot.img mnt
sudo cp pawboot.sys mnt/PAWBOOT.SYS
sudo umount mnt
rmdir mnt
