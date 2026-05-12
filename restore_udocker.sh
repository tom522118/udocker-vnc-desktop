#!/bin/bash

# ==========================================================
# 腳本名稱: restore_udocker.sh
# 功能描述: 全自動還原環境 (包含 Python 依賴自動安裝)
# ==========================================================

BACKUP_FILE=$1

if [ -z "$BACKUP_FILE" ]; then
    echo "用法: bash restore_udocker.sh <備份檔路徑>"
    exit 1
fi

echo "----------------------------------------------------------"
echo " [1/3] 正在檢查與安裝系統依賴 (Python)..."
echo "----------------------------------------------------------"

# 定義安裝工具 (自動偵測是否需要 sudo)
INSTALL_CMD="apt install -y"
if command -v sudo &> /dev/null; then
    INSTALL_CMD="sudo apt install -y"
    if [ "$(id -u)" -ne 0 ]; then
        sudo apt update
    fi
else
    apt update
fi

# 1. 安裝 Python3 與 python-is-python3 (解決 env python 找不到的問題)
echo " >>> 正在確保 Python3 與指令連結已就緒..."
$INSTALL_CMD python3 python-is-python3

if ! command -v python &> /dev/null; then
    echo " [!] 警告: 無法自動建立 python 連結，嘗試手動建立..."
    if command -v sudo &> /dev/null; then
        sudo ln -sf /usr/bin/python3 /usr/bin/python
    else
        ln -sf /usr/bin/python3 /usr/bin/python
    fi
fi

echo "----------------------------------------------------------"
echo " [2/3] 正在將資料還原至家目錄: $HOME"
echo "----------------------------------------------------------"

# 解壓縮
tar -zxvf $BACKUP_FILE -C $HOME

echo "----------------------------------------------------------"
echo " [3/3] 正在初始化 udocker 執行環境..."
echo "----------------------------------------------------------"

# 設定路徑
export PATH=$HOME/udocker_bin/udocker-1.3.17/udocker:$PATH

# 偵測是否需要 --allow-root
UDOCKER_OPT=""
[ "$(id -u)" -eq 0 ] && UDOCKER_OPT="--allow-root"

# 執行初始化
$HOME/udocker_bin/udocker-1.3.17/udocker/udocker $UDOCKER_OPT install

echo "----------------------------------------------------------"
echo " ✅ 還原成功！"
echo " 您現在可以執行：bash $HOME/udocker/start_desktop.sh"
echo "----------------------------------------------------------"
