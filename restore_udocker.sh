#!/bin/bash

# ==========================================================
# 腳本名稱: restore_udocker.sh
# 功能描述: 將備份還原至目前使用者的家目錄 (含環境檢查)
# ==========================================================

BACKUP_FILE=$1

if [ -z "$BACKUP_FILE" ]; then
    echo "用法: bash restore_udocker.sh <備份檔路徑>"
    exit 1
fi

echo "----------------------------------------------------------"
echo " [1/3] 正在檢查系統依賴環境 (Python)..."
echo "----------------------------------------------------------"

# 1. 檢查並安裝 python3 (需要 sudo 權限或 root)
if ! command -v python3 &> /dev/null; then
    echo " >>> 偵測到未安裝 python3，正在嘗試安裝..."
    sudo apt update && sudo apt install -y python3
else
    echo " >>> Python 3 已安裝."
fi

# 2. 解決 'python' 指令不存在的問題 (udocker 依賴此指令)
if ! command -v python &> /dev/null; then
    echo " >>> 建立 python -> python3 的連結..."
    sudo ln -sf /usr/bin/python3 /usr/bin/python || \
    alias python=python3
fi

echo "----------------------------------------------------------"
echo " [2/3] 正在還原資料到目前家目錄: $HOME"
echo "----------------------------------------------------------"

# 解壓縮到當前使用者的家目錄
tar -zxvf $BACKUP_FILE -C $HOME

echo " [3/3] 正在初始化 udocker 環境..."
export PATH=$HOME/udocker_bin/udocker-1.3.17/udocker:$PATH

# 偵測是否需要 --allow-root
UDOCKER_OPT=""
[ "$(id -u)" -eq 0 ] && UDOCKER_OPT="--allow-root"

# 再次確保執行權限
chmod +x $HOME/udocker_bin/udocker-1.3.17/udocker/udocker

$HOME/udocker_bin/udocker-1.3.17/udocker/udocker $UDOCKER_OPT install

echo "----------------------------------------------------------"
echo " 還原完成！您現在可以執行："
echo " bash $HOME/udocker/start_desktop.sh"
echo "----------------------------------------------------------"

