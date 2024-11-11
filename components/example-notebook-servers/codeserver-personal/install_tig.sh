#!/bin/bash

TIG_VERSION=2.5.4
curl -Lo tig-${TIG_VERSION}.tar.gz "https://github.com/jonas/tig/releases/download/tig-${TIG_VERSION}/tig-${TIG_VERSION}.tar.gz"
tar xf tig-${TIG_VERSION}.tar.gz
apt -yq update && apt install -yq libncurses-dev
make -C tig-${TIG_VERSION} prefix=/usr/local
make -C tig-${TIG_VERSION} install prefix=/usr/local
rm -rf tig-${TIG_VERSION}
rm tig-${TIG_VERSION}.tar.gz
apt uninstall -yq libncurses-dev
apt clean
rm -rf /var/lib/apt/lists/*
