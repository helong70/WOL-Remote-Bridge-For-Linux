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
    # 检查frpc是否已启动
    result = subprocess.run(["pgrep", "-f", FRPC_PATH], capture_output=True)
    if result.returncode == 0:
        return  # 已启动
    # 启动frpc
    subprocess.Popen([FRPC_PATH, "-c", FRPC_TOML])

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
