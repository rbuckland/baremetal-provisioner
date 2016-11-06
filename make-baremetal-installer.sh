#!/bin/bash


#
# Make the docker image that is the "base for our installation OS"
./make-docker.sh

#
# pull down the DIB docker image (tooling)
docker pull rbuckland/disk-image-builder:latest

# build a kernel and a ramdisk
docker run --privileged --rm -ti -v `pwd`:/x -v /var/run/docker.sock:/var/run/docker.sock rbuckland/disk-image-builder:latest /x/make-ramdisk.sh rbuckland/baremetal-os /x
