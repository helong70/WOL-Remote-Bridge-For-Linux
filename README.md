
# WOL 工具项目

本项目是一个基于 Python 和 frp 的远程唤醒（Wake-on-LAN）与内网穿透工具，适用于树莓派、开发板等 Linux 设备。通过 Flask 提供 Web API，可远程发送魔术包唤醒局域网内的主机，并结合 frp 实现公网穿透，支持手机等终端安全访问和控制。

主要功能：
- 提供基于 HTTP 的远程唤醒接口
- 支持 frp stcp 模式安全内网穿透
- 一键脚本部署与 systemd 开机自启
- 适合自动化、远程维护、智能家居等场景

## 目录结构


```
create_venv.sh                  # 创建 Python 虚拟环境的脚本
requirements.txt                # Python 依赖包列表
wlo.py                          # 主 Python 脚本
run_wlo.sh                      # 一键运行主程序脚本
setup_autostart.sh              # 一键设置 systemd 开机自启脚本
venv/                           # Python 虚拟环境目录（建议本地忽略）
frp/                            # frp 相关文件夹
   ├── frp_0.64.0_linux_arm64/        # frp 客户端目录
   │     ├── frpc                    # frp 客户端可执行文件
   │     ├── frpc.toml               # frp 客户端配置文件
   │     └── LICENSE                 # frp 许可证文件
frps_deploy/                  # frps 服务端一键部署脚本及配置
   ├── deploy_frps.sh          # frps 一键部署脚本（Linux
```


## frps 服务端一键部署（公网服务器端）

本项目已内置 frps 服务端一键部署脚本，适用于 Linux x86_64 环境，支持自动下载、解压、生成配置和一键启动。

### 使用方法

1. 上传 `frps_deploy/deploy_frps.sh` 到你的服务器。
2. 赋予脚本执行权限并运行：
   ```bash
   chmod +x frps_deploy/deploy_frps.sh
   bash frps_deploy/deploy_frps.sh
   ```
3. 部署完成后，进入生成的 frp 目录，编辑 `frps.toml` 配置文件（默认已生成示例，需根据实际情况修改 token、端口等参数）。
4. 启动 frps 服务：
   ```bash
   cd frp_0.64.0_linux_amd64
   ./start_frps.sh
   ```

> 脚本会自动生成 `frps.toml` 配置文件，默认内容如下：
> ```toml
> [common]
> bind_port = 7000
> token = "你的token"
> # dashboard_port = 7500
> # dashboard_user = "admin"
> # dashboard_pwd = "admin"
> authentication_method = "token"
> ```

> 日志输出在 frps.log 文件中。

---

## 快速开始

1. **创建虚拟环境**
   ```bash
   bash create_venv.sh
   ```
2. **安装依赖**
   ```bash
   source venv/bin/activate
   pip install -r requirements.txt
   ```
3. **运行主程序**
   ```bash
   python wlo.py
   ```

4. **frp 使用说明**
   - frp 客户端已包含在 `frp/frp_0.64.0_linux_arm64/` 目录下。
   - 配置文件为 `frpc.toml`，可根据实际需求修改。
   - 启动 frpc：
     ```bash
     ./frp/frp_0.64.0_linux_arm64/frpc -c ./frp/frp_0.64.0_linux_arm64/frpc.toml
     ```


## 开机自启设置

推荐使用 systemd 管理脚本开机自启。

1. 运行自动设置脚本：
   ```bash
   bash setup_autostart.sh
   ```
   该脚本会自动创建 systemd 服务并设置 /home/WOL/run_wlo.sh 开机自启。

2. 手动管理服务：
   ```bash
   sudo systemctl status wlo      # 查看服务状态
   sudo systemctl restart wlo     # 重启服务
   sudo systemctl stop wlo        # 停止服务
   sudo systemctl disable wlo     # 取消开机自启
   ```

## 远程唤醒电脑方法

本项目启动后，会在服务器上开放 Web API（默认端口可在 wlo.py 配置），用于远程唤醒局域网内的主机。

> 说明：若 frp stcp 隧道已打通，也可以直接通过本地 IP + 端口访问 Web API，无需公网地址。例如：
> 
> ```
> http://127.0.0.1:5000/wol?mac=XX-XX-XX-XX-XX-XX
> ```
> 
> 其中 127.0.0.1:5000 可替换为实际本地监听的 IP 和端口。

### 访问方式说明

#### 1. 浏览器访问

- 公网访问（frp/stcp 已配置好公网穿透）：
   ```
   http://your-server:端口/wol?mac=XX-XX-XX-XX-XX-XX
   ```
- 局域网/本地访问（stcp 隧道打通或本地直连）：
   ```
   http://本地IP:端口/wol?mac=XX-XX-XX-XX-XX-XX
   ```

> 其中 `mac` 参数为你要唤醒的主机的 MAC 地址（支持 `-` 或 `:` 分隔）。
> 访问后页面会返回唤醒结果。

#### 2. 命令行（curl）访问

- 公网访问：
   ```bash
   curl "http://your-server:端口/wol?mac=XX-XX-XX-XX-XX-XX"
   ```
- 局域网/本地访问：
   ```bash
   curl "http://本地IP:端口/wol?mac=XX-XX-XX-XX-XX-XX"
   ```

如需指定目标主机的 IP 地址（部分场景下可选）：

```bash
curl "http://your-server:端口/wol?mac=XX-XX-XX-XX-XX-XX&ip=192.168.1.100"
```

---

- `download_and_extract_frp.sh` 可用于下载并解压 frp。
- 如需自定义配置，请参考 frp 官方文档。

## 许可证
本项目部分内容基于 frp，遵循其 LICENSE 文件。
