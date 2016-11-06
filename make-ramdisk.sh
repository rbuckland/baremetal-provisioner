#!/bin/bash

export DIB_DOCKER_IMAGE="$1"
export DISTRO_NAME=ubuntu
export DIB_RELEASE=xenial

ramdisk-image-create -o deploy.ramdisk docker dpkg deploy-baremetal  && \

mv deploy.ramdisk.initramfs $2/ && \

mv deploy.ramdisk.kernel $2/

