#!/bin/bash
# 创建Python虚拟环境并安装依赖

set -e

cd "$(dirname "$0")"

python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

echo "虚拟环境已创建并安装依赖。使用方法："
echo "source venv/bin/activate"
