# RunPod udocker VNC Desktop 專案

本專案提供了一套在 RunPod (或其他 Linux 環境) 中使用 `udocker` 建立免 root 權限的 XFCE 桌面環境與 noVNC 網頁介面的自動化腳本。

## 📁 專案結構

- `start_desktop.sh`: 啟動腳本。啟動容器、VNC 伺服器與 noVNC。
- `backup_udocker.sh`: 備份腳本。打包所有程式、映像檔與設定。
- `restore_udocker.sh`: 還原腳本。在新環境中解壓並恢復環境。
- `readme.txt`: 原始環境配置說明 (Dockerfile 格式)。

## 🚀 快速開始

### 1. 啟動桌面環境
執行以下指令即可啟動 VNC 與 noVNC 服務：
```bash
bash /root/udocker/start_desktop.sh
```
啟動成功後，請透過瀏覽器存取：`http://<您的-IP>:6080`

### 2. 備份專案
如果您需要移動到其他 RunPod 主機，請執行：
```bash
bash /root/udocker/backup_udocker.sh
```
備份檔將儲存在 `/root/udocker_backup/` 目錄下。

### 3. 還原專案
在新主機上，將備份檔上傳後執行：
```bash
bash /root/udocker/restore_udocker.sh <備份檔路徑>
```

## 🛠️ 技術細節
- **基礎映像檔**: Ubuntu 22.04
- **桌面環境**: XFCE4
- **瀏覽器**: Firefox (PPA 版)
- **工具**: TigerVNC, websockify (noVNC)
- **容器技術**: udocker (1.3.17)

## 📝 Git 說明
本專案已執行 `git init`。
- 排除目錄: `udocker_backup/` (備份檔體積較大，不納入版本控制)。
- 首次提交: 已包含所有核心腳本與設定檔。
