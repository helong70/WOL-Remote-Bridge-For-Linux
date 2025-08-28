#!/bin/bash
# 下载并解压 frp 到 /frp 目录

set -e

# 检查网络连通性
echo "检查网络连通性..."
if ! curl -I -s --connect-timeout 5 https://github.com > /dev/null; then
    echo "无法连接到 github.com，请检查网络。"
    exit 1
fi
echo "网络正常，开始下载。"

FRP_URL="https://github.com/fatedier/frp/releases/download/v0.64.0/frp_0.64.0_linux_arm64.tar.gz"
FRP_DIR="/frp"
FRP_TAR="frp_0.64.0_linux_arm64.tar.gz"

mkdir -p "$FRP_DIR"
cd "$FRP_DIR"

# 下载
if [ ! -f "$FRP_TAR" ]; then
    echo "正在下载 $FRP_URL ..."
    curl -L -o "$FRP_TAR" "$FRP_URL"
else
    echo "$FRP_TAR 已存在，跳过下载。"
fi

# 解压
if [ ! -d "frp_0.64.0_linux_arm64" ]; then
    echo "正在解压 $FRP_TAR ..."
    tar -xzvf "$FRP_TAR"
else
    echo "frp_0.64.0_linux_arm64 已存在，跳过解压。"
fi

echo "frp 已下载并解压到 $FRP_DIR/frp_0.64.0_linux_arm64/"
