#!/bin/bash

# ==========================================================
# 腳本名稱: restore_udocker.sh
# 功能描述: 將備份還原至目前使用者的家目錄
# ==========================================================

BACKUP_FILE=$1

if [ -z "$BACKUP_FILE" ]; then
    echo "用法: bash restore_udocker.sh <備份檔路徑>"
    exit 1
fi

echo "----------------------------------------------------------"
echo " [1/2] 正在還原資料到目前家目錄: $HOME"
echo "----------------------------------------------------------"

# 解壓縮到當前使用者的家目錄
tar -zxvf $BACKUP_FILE -C $HOME

echo " [2/2] 正在初始化 udocker 環境..."
export PATH=$HOME/udocker_bin/udocker-1.3.17/udocker:$PATH

# 偵測是否需要 --allow-root
UDOCKER_OPT=""
[ "$(id -u)" -eq 0 ] && UDOCKER_OPT="--allow-root"

udocker $UDOCKER_OPT install

echo "----------------------------------------------------------"
echo " 還原完成！您現在可以執行："
echo " bash $HOME/udocker/start_desktop.sh"
echo "----------------------------------------------------------"

