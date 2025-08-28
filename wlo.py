
def check_internet(host="8.8.8.8", port=53, timeout=3):
    import socket
    try:
        socket.setdefaulttimeout(timeout)
        socket.socket(socket.AF_INET, socket.SOCK_STREAM).connect((host, port))
        return True
    except Exception:
        return False
import os
import subprocess
from flask import Flask, request, jsonify

# 配置参数
FRPC_PATH = "frp/frp_0.64.0_linux_arm64/frpc"
FRPC_TOML = "frp/frp_0.64.0_linux_arm64/frpc.toml"



def ensure_frpc_toml():
    if not os.path.exists(FRPC_TOML):
        os.makedirs(os.path.dirname(FRPC_TOML), exist_ok=True)
        with open(FRPC_TOML, "w", encoding="utf-8") as f:
            f.write("# 请根据实际需求编辑 frpc.toml 配置文件\n")
        print(f"已创建空的 {FRPC_TOML}，请手动编辑配置内容！")


def start_frpc():
    import time, signal
    frpc_proc = None
    while True:
        # 等待联网
        while not check_internet():
            print("等待联网...")
            time.sleep(3)
        # 启动frpc
        print("检测到联网，启动frpc...")
        frpc_proc = subprocess.Popen([FRPC_PATH, "-c", FRPC_TOML])
        # 监控网络状态
        while check_internet():
            # 检查frpc进程是否意外退出
            if frpc_proc.poll() is not None:
                print("frpc 进程已退出，尝试重启...")
                break
            time.sleep(3)
        # 断网，终止frpc
        if frpc_proc and frpc_proc.poll() is None:
            print("检测到断网，结束frpc进程...")
            frpc_proc.terminate()
            try:
                frpc_proc.wait(timeout=5)
            except Exception:
                frpc_proc.kill()
        print("等待网络恢复...")

# 唤醒函数
def wake_on_lan(mac, port=9):
    # 发送魔术包到本地9端口
    try:
        import wakeonlan
        wakeonlan.send_magic_packet(mac, port=port)
        return True
    except ImportError:
        # 没有wakeonlan库，尝试用shell
        cmd = f"wakeonlan -p {port} {mac}"
        return os.system(cmd) == 0

app = Flask(__name__)

@app.route("/wol/<mac>", methods=["POST", "GET"])
def wol(mac):
    mac = mac.replace("-", ":").replace(".", ":")
    ok = wake_on_lan(mac)
    return jsonify({"mac": mac, "wake": ok})

if __name__ == "__main__":
    ensure_frpc_toml()
    start_frpc()
    app.run(host="0.0.0.0", port=5000)
