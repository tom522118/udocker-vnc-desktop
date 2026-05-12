#!/bin/bash

# 1. 自動設定 udocker 路徑 (使用 $HOME)
export PATH=$HOME/udocker_bin/udocker-1.3.17/udocker:$PATH

# 2. 自動偵測是否為 root 使用者
UDOCKER_CMD="udocker"
if [ "$(id -u)" -eq 0 ]; then
    UDOCKER_CMD="udocker --allow-root"
fi

CONTAINER_NAME="vnc-desktop"

echo "----------------------------------------------------------"
echo " 正在啟動 Hybrid 桌面環境 (XFCE Panel + Openbox)..."
echo "----------------------------------------------------------"

# 停止可能殘留的進程
bash stop_desktop.sh 2>/dev/null

# 啟動容器 (執行容器內的 run_all.sh)
nohup $UDOCKER_CMD run \
    --user=root \
    --publish=6080:6080 \
    $CONTAINER_NAME bash /root/run_all.sh > $HOME/udocker/desktop_output.log 2>&1 &

echo " ✅ 啟動指令已送出。請在 5 秒後存取: http://localhost:6080"
echo "----------------------------------------------------------"
