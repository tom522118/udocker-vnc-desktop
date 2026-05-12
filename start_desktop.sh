#!/bin/bash

# ==========================================================
# 腳本名稱: start_desktop.sh
# 功能描述: 啟動 udocker 內的 XFCE 桌面與 noVNC 服務 (自動偵測使用者)
# ==========================================================

# 1. 自動設定 udocker 路徑 (使用 $HOME)
export PATH=$HOME/udocker_bin/udocker-1.3.17/udocker:$PATH

# 2. 自動偵測是否為 root 使用者，決定是否加入 --allow-root
UDOCKER_CMD="udocker"
if [ "$(id -u)" -eq 0 ]; then
    UDOCKER_CMD="udocker --allow-root"
    echo " >>> 偵測到以 root 身分執行，已自動加入 --allow-root"
fi

# 容器名稱
CONTAINER_NAME="vnc-desktop"

echo "----------------------------------------------------------"
echo " [1/3] 正在準備啟動容器: $CONTAINER_NAME..."
echo "       使用者家目錄: $HOME"
echo "----------------------------------------------------------"

# 啟動指令
echo " [2/3] 正在執行 $UDOCKER_CMD run 指令..."

$UDOCKER_CMD run \
    --user=root \
    --publish=6080:6080 \
    $CONTAINER_NAME bash -c '
        vncserver -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE && \
        openssl req -new -subj "/C=JP" -x509 -days 365 -nodes -out self.pem -keyout self.pem && \
        websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901 && \
        echo "----------------------------------------------------------" && \
        echo " [3/3] 啟動成功！請在瀏覽器開啟: http://localhost:6080" && \
        echo "----------------------------------------------------------" && \
        tail -f /dev/null
    '
