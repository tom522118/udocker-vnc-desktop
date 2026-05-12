# RunPod udocker VNC Desktop 專案

本專案提供了一套在 RunPod (或其他 Linux 環境) 中使用 `udocker` 建立免 root 權限的 XFCE 桌面環境與 noVNC 網頁介面的自動化腳本。

## 📥 取得本專案

您可以透過以下三種方式取得此專案：

### 1. 使用 Git HTTPS (最推薦)
如果您在新的 RunPod 或 Linux 主機上，請執行：
```bash
git clone https://github.com/tom522118/udocker-vnc-desktop.git
cd udocker-vnc-desktop
```

### 2. 使用 Git SSH
如果您已配置 SSH Key，請執行：
```bash
git clone git@github.com:tom522118/udocker-vnc-desktop.git
cd udocker-vnc-desktop
```

### 3. 下載 ZIP 壓縮檔
如果您不想使用 Git，可以下載 ZIP 並解壓縮：
```bash
wget https://github.com/tom522118/udocker-vnc-desktop/archive/refs/heads/master.zip
unzip master.zip
cd udocker-vnc-desktop-master
```

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

## 📖 操作說明 (Operation Manual)

本專案已完成初始化，以下是完整的操作流程說明，幫助您在不同主機間遷移環境。

### 1. 首次安裝與配置 (已完成)
- 已安裝 `udocker 1.3.17` 於 `/root/udocker_bin`。
- 已建立 `vnc-desktop` 容器，並安裝 XFCE4、Firefox、TigerVNC。
- 已建立 `start_desktop.sh` 作為統一啟動入口。

### 2. 日常啟動服務
當您想要開始使用桌面時：
```bash
cd /root/udocker
bash start_desktop.sh
```
啟動後，開啟瀏覽器存取 `http://<主機IP>:6080` 即可。

### 3. 環境備份 (重要)
如果您完成了重要的設定或安裝了新軟體，請執行備份：
```bash
bash /root/udocker/backup_udocker.sh
```
- **備份內容**：udocker 程式、所有映像檔、所有容器、以及啟動/還原腳本。
- **儲存位置**：`/root/udocker_backup/udocker_full_backup_時間戳記.tar.gz`。
- **建議**：請將此 `.tar.gz` 檔下載至您的個人電腦或雲端硬碟存放，因為 GitHub 不會儲存此巨大檔案。

### 4. 遷移至新主機 (還原流程)
當您租用新的 RunPod 或在其他 Linux 主機上時：

1. **取得腳本**：
   ```bash
   git clone https://github.com/tom522118/udocker-vnc-desktop.git
   cd udocker-vnc-desktop
   ```
2. **上傳備份檔**：將您的 `.tar.gz` 備份檔上傳到該主機（例如上傳到 `/root/`）。
3. **執行還原**：
   ```bash
   bash restore_udocker.sh /root/您的備份檔名.tar.gz
   ```
4. **立即啟動**：還原完成後即可直接執行 `bash start_desktop.sh`。

## 🛠️ 腳本詳細說明 (Script Technical Explanation)

本專案的核心在於確保環境的可移植性。以下是備份與還原腳本的邏輯說明：

### 1. 備份腳本 (`backup_udocker.sh`)
此腳本採用 `tar` 指令進行封裝，主要執行以下邏輯：
- **環境檢查**：自動建立 `/root/udocker_backup` 目錄。
- **資料打包**：
  - `/root/udocker_bin`: 包含 `udocker` 的執行程式與 Python 依賴環境。
  - `/root/.udocker`: 這是最重要的目錄，包含所有已下載的 Docker Layer、容器設定以及您在容器內安裝的所有軟體（如 Firefox、XFCE）。
  - `/root/udocker/*.sh`: 包含啟動與還原用的所有自動化腳本。
- **壓縮優化**：使用 `-z` (gzip) 壓縮以減少檔案體積，並保留原始檔案權限。

### 2. 還原腳本 (`restore_udocker.sh`)
此腳本用於在新主機上重建環境：
- **路徑還原**：將備份檔解壓至根目錄 `/`。由於備份時採用絕對路徑，解壓後會自動回到原位。
- **環境初始化**：
  - `export PATH`: 暫時性地將 udocker 加入系統路徑，以便執行指令。
  - `udocker install`: 這是關鍵步驟，它會重新連結與校驗解壓後的工具鏈，確保在不同主機的內核環境下 udocker 仍能正常調用 Proot 或 RunC 引擎。
- **權限修復**：確保所有啟動腳本具備執行權限。

## 📝 Git 說明
本專案已執行 `git init`。
- 排除目錄: `udocker_backup/` (備份檔體積較大，不納入版本控制)。
- 首次提交: 已包含所有核心腳本與設定檔。
