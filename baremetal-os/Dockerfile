FROM ubuntu:16.04

LABEL build.publish.version="0.2"
LABEL build.publish.username="rbuckland"

ENV DEBIAN_FRONTEND=noninteractive

ARG USERNAME=master
ARG PASSWORD=password

RUN apt-get update \
    && apt-get install -y apt-transport-https ca-certificates \
                          mcrypt e2fsprogs vim sudo linux-image-generic openssh-server qemu-utils

#
# Basic user setup
#

RUN useradd -m -G sudo ${USERNAME}  && \
    echo "${USERNAME}:${PASSWORD}" | chpasswd -c SHA512
