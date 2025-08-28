#!/bin/bash
# 启动 wlo.py 脚本

# 激活虚拟环境（如有）
if [ -d "venv" ]; then
    source venv/bin/activate
fi



# 运行主程序
python wlo.py
