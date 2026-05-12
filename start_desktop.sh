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
        # [關鍵修復] 清理殘留鎖定檔與 D-Bus 檔案
        rm -rf /tmp/.X*-lock /tmp/.X11-unix/X* /tmp/.ICE-unix/ /root/.vnc/*.log /root/.vnc/*.pid
        rm -rf /var/run/dbus/pid /root/.dbus/

        echo " >>> [容器內] 正在初始化 D-Bus 服務 (Session Bus)..." && \
        mkdir -p /var/lib/dbus && \
        dbus-uuidgen > /var/lib/dbus/machine-id && \
        # 啟動 Session Bus 並匯入環境變數
        export $(dbus-launch) && \

        echo " >>> [容器內] 正在啟動 TigerVNC Server (Display :1)..." && \
        vncserver :1 -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE && \
        
        echo " >>> [容器內] 正在生成 SSL 憑證 (self.pem)..." && \
        openssl req -new -subj "/C=JP" -x509 -days 365 -nodes -out self.pem -keyout self.pem && \
        
        echo " >>> [容器內] 正在啟動 websockify (noVNC 網頁代理)..." && \
        websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 127.0.0.1:5901 && \
        echo "----------------------------------------------------------" && \
        echo " [3/3] 啟動成功！請在瀏覽器開啟: http://localhost:6080" && \
        echo "----------------------------------------------------------" && \
        tail -f /dev/null
    '
