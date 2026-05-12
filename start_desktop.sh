#!/bin/bash

# ==========================================================
# 腳本名稱: start_desktop.sh
# 功能描述: 啟動 udocker 內的 XFCE 桌面與 noVNC 服務
# ==========================================================

# 設定 udocker 路徑
export PATH=/root/udocker_bin/udocker-1.3.17/udocker:$PATH

# 容器名稱
CONTAINER_NAME="vnc-desktop"

echo "----------------------------------------------------------"
echo " [1/3] 正在檢查環境並準備啟動容器: $CONTAINER_NAME..."
echo "----------------------------------------------------------"

echo " >>> 提示: VNC 伺服器將在容器內啟動"
echo " >>> 提示: noVNC 網頁服務將對應到主機的 6080 埠號"

# 啟動指令 (依照 readme.txt)
echo " [2/3] 正在執行 udocker run 指令..."
echo "       (這會啟動 VNC server, 生成 SSL 憑證並啟動 websockify)"

udocker --allow-root run \
    --user=root \
    --publish=6080:6080 \
    $CONTAINER_NAME bash -c '
        echo " >>> [容器內] 正在啟動 TigerVNC Server (1024x768)..." && \
        vncserver -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE && \
        
        echo " >>> [容器內] 正在生成 SSL 憑證 (self.pem)..." && \
        openssl req -new -subj "/C=JP" -x509 -days 365 -nodes -out self.pem -keyout self.pem && \
        
        echo " >>> [容器內] 正在啟動 websockify (noVNC 網頁代理)..." && \
        websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901 && \
        
        echo "----------------------------------------------------------" && \
        echo " [3/3] 啟動成功！服務已在後台運行。" && \
        echo "       請在瀏覽器開啟: http://localhost:6080" && \
        echo "       (若在遠端主機，請使用該主機的 IP 位址)" && \
        echo "----------------------------------------------------------" && \
        
        tail -f /dev/null
    '
