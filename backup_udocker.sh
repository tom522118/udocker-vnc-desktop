#!/bin/bash

# ==========================================================
# 腳本名稱: backup_udocker.sh
# 功能描述: 備份專案 (支援跨使用者還原)
# ==========================================================

DATE=$(date +%Y%m%d_%H%M)
BACKUP_FILE="udocker_portable_backup_${DATE}.tar.gz"
BACKUP_DIR="$HOME/udocker_backup"

mkdir -p $BACKUP_DIR

echo "----------------------------------------------------------"
echo " [1/2] 正在開始打包資料 (使用相對路徑以支援跨使用者還原)..."
echo "       目前家目錄: $HOME"
echo "----------------------------------------------------------"

# 切換到家目錄，使用相對路徑打包，這樣還原時就會解壓到新的 $HOME
cd $HOME
tar -zcvf $BACKUP_DIR/$BACKUP_FILE \
    udocker_bin \
    .udocker \
    udocker/start_desktop.sh \
    udocker/restore_udocker.sh \
    udocker/README.md

echo "----------------------------------------------------------"
echo " [2/2] 備份成功！"
echo "       檔案路徑: $BACKUP_DIR/$BACKUP_FILE"
echo "       此檔案現在可以還原到任何使用者的家目錄下。"
echo "----------------------------------------------------------"
