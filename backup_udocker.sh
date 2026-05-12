#!/bin/bash

# ==========================================================
# 腳本名稱: backup_udocker.sh
# 功能描述: 備份所有 udocker 相關程式、數據與腳本
# ==========================================================

# 定義備份檔名與目錄
DATE=$(date +%Y%m%d_%H%M)
BACKUP_FILE="udocker_full_backup_${DATE}.tar.gz"
BACKUP_DIR="/root/udocker_backup"

echo "----------------------------------------------------------"
echo " [1/3] 正在準備備份環境..."
echo "----------------------------------------------------------"
mkdir -p $BACKUP_DIR
echo " >>> 備份目錄: $BACKUP_DIR"
echo " >>> 目標檔案: $BACKUP_FILE"

echo " [2/3] 正在打包核心資料..."
echo "       包含: udocker 程式、容器映像檔、啟動腳本"
echo "       (請耐心等候，這取決於您的容器大小...)"

# 執行打包
tar -zcvf $BACKUP_DIR/$BACKUP_FILE \
    /root/udocker_bin \
    /root/.udocker \
    /root/udocker/start_desktop.sh \
    /root/udocker/restore_udocker.sh

if [ $? -eq 0 ]; then
    echo "----------------------------------------------------------"
    echo " [3/3] 備份成功！"
    echo "       檔案路徑: $BACKUP_DIR/$BACKUP_FILE"
    echo "       您可以將此檔案移動到其他主機進行還原。"
    echo "----------------------------------------------------------"
else
    echo " [!] 錯誤: 備份過程中出現問題。"
    exit 1
fi
