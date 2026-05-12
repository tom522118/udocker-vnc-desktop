#!/bin/bash

# ==========================================================
# 腳本名稱: restore_udocker.sh
# 功能描述: 在新主機上還原備份的 udocker 環境
# ==========================================================

BACKUP_FILE=$1

echo "----------------------------------------------------------"
echo " [1/3] 正在檢查備份檔案..."
echo "----------------------------------------------------------"

if [ -z "$BACKUP_FILE" ]; then
    echo " [!] 錯誤: 未提供備份檔路徑。"
    echo "     用法: bash restore_udocker.sh <備份檔路徑>"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo " [!] 錯誤: 找不到檔案: $BACKUP_FILE"
    exit 1
fi

echo " >>> 找到備份檔: $BACKUP_FILE"

echo " [2/3] 正在將資料還原至系統目錄..."
# 解壓到根目錄 (維持原來的絕對路徑結構)
tar -zxvf $BACKUP_FILE -C /

echo " [3/3] 正在重新連結 udocker 執行環境..."
export PATH=/root/udocker_bin/udocker-1.3.17/udocker:$PATH
udocker --allow-root install

echo "----------------------------------------------------------"
echo " 還原完成！"
echo " 您現在可以執行以下指令啟動桌面："
echo " bash /root/udocker/start_desktop.sh"
echo "----------------------------------------------------------"

