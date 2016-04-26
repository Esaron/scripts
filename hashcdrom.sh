#!/bin/bash

#Obtained from https://help.ubuntu.com/community/HowToMD5SUM

#Compares the checksums of an iso9660 image and a burned disk.
#This script is released into the public domain by it's author.
if [ -n "$BASH" ]; then
shopt -s expand_aliases
fi

if [ -n "$FILE" ]; then
FILE="$FILE"
else
FILE=`basename $0`
fi

if [ -n "$CHECKSUM" ]; then
alias CHECKSUM="$CHECKSUM"
elif which md5deep &> /dev/null; then
alias CHECKSUM='md5deep -e'
else
alias CHECKSUM='md5sum'
fi

if [ -n "$2" ]; then
DISKDEVICE="$2"
else
DISKDEVICE='/dev/cdrom'
fi

if [ -n "$1" ]; then
CSUM1=$(CHECKSUM "$1" | grep --only-matching -m 1 '^[0-9a-f]*')
echo 'checksum for input image:' $CSUM1
SIZE=$(stat -c '%s' "$1");
BLOCKS=$(expr $SIZE / 2048);
CSUM2=$(dd if="$DISKDEVICE" bs=2048 count=$BLOCKS 2> /dev/null | CHECKSUM | grep --only-matching -m 1 '^[0-9a-f]*')
echo 'checksum for output disk:' $CSUM2

if [ "$CSUM1" = "$CSUM2" ]; then
echo 'verification successful!'
else
echo 'verification failed!'
fi

else
echo ''
echo 'Usage:'
echo '  '$FILE' /path/to/iso [/path/to/cd/drive]'
echo ''
fi
