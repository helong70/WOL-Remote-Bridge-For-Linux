#!/bin/bash
# 一键部署 frps 服务端脚本
# 适用于 Linux x86_64

set -e

FRPS_VERSION=0.64.0
FRPS_DIR=frp_${FRPS_VERSION}_linux_amd64
FRPS_TAR=frp_${FRPS_VERSION}_linux_amd64.tar.gz
DOWNLOAD_URL=https://github.com/fatedier/frp/releases/download/v${FRPS_VERSION}/${FRPS_TAR}

# 下载 frps
if [ ! -f "$FRPS_TAR" ]; then
    echo "正在下载 $FRPS_TAR ..."
    wget $DOWNLOAD_URL
fi

# 解压
if [ ! -d "$FRPS_DIR" ]; then
    tar -zxvf $FRPS_TAR
fi

# 生成 frps.toml 示例
cat > $FRPS_DIR/frps.toml <<EOF
[common]
bind_port = 7000
token = "你的token"

# dashboard 配置（可选）
# dashboard_port = 7500
# dashboard_user = "admin"
# dashboard_pwd = "admin"

# stcp 需要指定 authentication_method
authentication_method = "token"
EOF

# 生成一键启动脚本
cat > $FRPS_DIR/start_frps.sh <<EOF
#!/bin/bash
cd $(pwd)/$FRPS_DIR
nohup ./frps -c frps.toml > frps.log 2>&1 &
echo "frps 已后台启动，日志见 frps.log"
EOF
chmod +x $FRPS_DIR/start_frps.sh

# 提示
cat <<TIP

部署完成！
请根据实际情况修改 $FRPS_DIR/frps.toml 配置文件。
启动 frps 服务：
  cd $FRPS_DIR
  ./start_frps.sh