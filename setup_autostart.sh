#!/bin/bash
# 设置 /home/WOL/run_wlo.sh 脚本为 systemd 服务并开机自启

SERVICE_NAME=wlo
SERVICE_FILE=/etc/systemd/system/${SERVICE_NAME}.service
SCRIPT_PATH=/home/WOL/run_wlo.sh

# 创建 systemd 服务文件
sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=Run WLO Python Service
After=network.target

[Service]
Type=simple
WorkingDirectory=/home/WOL
ExecStart=/bin/bash $SCRIPT_PATH
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 重新加载 systemd 配置
sudo systemctl daemon-reload
# 设置开机自启
sudo systemctl enable $SERVICE_NAME
# 启动服务
sudo systemctl start $SERVICE_NAME

echo "已设置 $SCRIPT_PATH 为 systemd 服务并开机自启。"
