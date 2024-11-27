#!/bin/bash

GIT_DELTA_VERSION=0.18.2
GIT_DELTA_ARCH=amd64

curl -Lo \
    git-delta_${GIT_DELTA_VERSION}_${GIT_DELTA_ARCH}.deb \
    https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_${GIT_DELTA_ARCH}.deb

dpkg -i git-delta_${GIT_DELTA_VERSION}_${GIT_DELTA_ARCH}.deb
rm git-delta_${GIT_DELTA_VERSION}_${GIT_DELTA_ARCH}.deb
