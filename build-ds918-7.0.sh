#!/bin/bash

# 安装依赖
apt-get update && apt-get install --yes --no-install-recommends ca-certificates build-essential git libssl-dev curl cpio bspatch vim gettext bc bison flex dosfstools kmod jq

# 新建目录 并 清除编译残留文件
cd /root && rm -rf dsm && mkdir dsm && cd ./dsm

# 下载 redpill
git clone https://github.com/RedPill-TTG/redpill-lkm.git
git clone https://github.com/RedPill-TTG/redpill-load.git

# 下载群晖 toolkit
curl --location "https://sourceforge.net/projects/dsgpl/files/toolkit/DSM7.0/ds.apollolake-7.0.dev.txz/download" --output ds.apollolake-7.0.dev.txz

mkdir apollolake
tar -C./apollolake/ -xf ds.apollolake-7.0.dev.txz usr/local/x86_64-pc-linux-gnu/x86_64-pc-linux-gnu/sys-root/usr/lib/modules/DSM-7.0/build

# 编译 redpill-lkm
cd redpill-lkm
make LINUX_SRC=../apollolake/usr/local/x86_64-pc-linux-gnu/x86_64-pc-linux-gnu/sys-root/usr/lib/modules/DSM-7.0/build
read -a KVERS <<< "$(modinfo --field=vermagic redpill.ko)" && cp -fv redpill.ko ../redpill-load/ext/rp-lkm/redpill-linux-v${KVERS[0]}.ko || exit 1
cd ..

# 编译 redpill-load
cd redpill-load
curl --location "https://raw.githubusercontent.com/hopolcn/redpill-build/master/user_config.DS918+.json" --output user_config.json
./build-loader.sh 'DS918+' '7.0-41890'
cd images && ls
