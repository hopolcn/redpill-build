#!/bin/bash

# 安装依赖
apt-get update && apt-get install --yes --no-install-recommends ca-certificates build-essential git libssl-dev curl cpio bspatch vim gettext bc bison flex dosfstools kmod jq

# 新建目录 并 清除编译残留文件
cd /root && rm -rf dsm && mkdir dsm && cd ./dsm

# 下载 redpill
git clone https://github.com/RedPill-TTG/redpill-lkm.git
git clone https://github.com/RedPill-TTG/redpill-load.git

# 下载 群晖 linux 内核
curl --location "https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/25426branch/apollolake-source/linux-4.4.x.txz/download" --output linux-4.4.x.txz

# 编译 redpill-lkm
cd redpill-lkm
tar -xf ../linux-4.4.x.txz
cd linux-4.4*
linuxsrc=`pwd`
cp synoconfigs/apollolake .config
echo '+' > .scmversion
make oldconfig ; make modules_prepare
cd ..
make LINUX_SRC=${linuxsrc}
read -a KVERS <<< "$(modinfo --field=vermagic redpill.ko)" && cp -fv redpill.ko ../redpill-load/ext/rp-lkm/redpill-linux-v${KVERS[0]}.ko || exit 1
cd ..

# 编译 redpill-load
cd redpill-load
curl --location "https://raw.githubusercontent.com/hopolcn/redpill-build/master/user_config.DS918+.json" --output user_config.json
./build-loader.sh 'DS918+' '6.2.4-25556'
cd images && ls
