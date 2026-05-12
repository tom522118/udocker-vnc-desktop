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
        # [關鍵修復] 徹底清理 VNC 與 D-Bus 殘留檔案
        rm -rf /tmp/.X*-lock /tmp/.X11-unix/X* /tmp/.ICE-unix/ /root/.vnc/*.log /root/.vnc/*.pid
        rm -rf /var/run/dbus/pid /root/.dbus/

        # 確保 D-Bus 機器碼存在
        mkdir -p /var/lib/dbus
        dbus-uuidgen > /var/lib/dbus/machine-id

        # [關鍵修復] 寫入強化的 xstartup 腳本，確保 D-Bus 與 XFCE 完美結合
        mkdir -p /root/.vnc
        cat << "EOF" > /root/.vnc/xstartup
#!/bin/bash
export USER=root
export HOME=/root
export XDG_RUNTIME_DIR=/tmp/runtime-root

# 確保目錄存在且權限正確 (在腳本執行時建立)
mkdir -p $XDG_RUNTIME_DIR
chmod 0700 $XDG_RUNTIME_DIR

unset DBUS_SESSION_BUS_ADDRESS
unset SESSION_MANAGER

# 正確啟動 dbus 並將變數匯出
export $(dbus-launch)

export XDG_CURRENT_DESKTOP="XFCE"
export XDG_MENU_PREFIX="xfce-"

# 使用 exec 取代背景執行，防止腳本提早結束
exec startxfce4
EOF
        chmod +x /root/.vnc/xstartup

        echo " >>> [容器內] 正在啟動 TigerVNC Server (使用 Display :1)..." && \
        vncserver :1 -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE && \
        
        echo " >>> [容器內] 正在生成 SSL 憑證 (self.pem)..." && \
        openssl req -new -subj "/C=JP" -x509 -days 365 -nodes -out self.pem -keyout self.pem && \
        
        echo " >>> [容器內] 正在啟動 websockify (noVNC 網頁代理)..." && \
        websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 127.0.0.1:5901 && \
        
        echo "----------------------------------------------------------" && \
        echo " ✅ 啟動成功！請在瀏覽器開啟: http://localhost:6080" && \
        echo "----------------------------------------------------------" && \
        
        tail -f /dev/null
    '
