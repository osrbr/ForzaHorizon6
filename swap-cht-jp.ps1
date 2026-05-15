```powershell
# =========================================================
# Forza Horizon 6 語言交換腳本
# CHT <-> JP
# =========================================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================"
Write-Host " FH6 語言交換工具"
Write-Host "========================================"
Write-Host ""

```powershell id="7ah9ov"
# -----------------------------
# 1. 取得目前腳本所在位置
# -----------------------------

$CurrentPath = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "[*] 目前路徑："
Write-Host "    $CurrentPath"
Write-Host ""

$GameRoot = $null

# -----------------------------
# 優先檢查目前路徑
# -----------------------------

$LocalStringTable = Join-Path `
    $CurrentPath `
    "media\Stripped\StringTables"

if (Test-Path $LocalStringTable) {

    Write-Host "[+] 偵測到目前資料夾為 FH6 遊戲目錄"

    $GameRoot = $CurrentPath
}
else {

    Write-Host "[*] 目前資料夾不是 FH6"
    Write-Host "[*] 正在搜尋 Steam 安裝位置..."
    Write-Host ""

    # -----------------------------
    # 尋找 Steam 安裝路徑
    # -----------------------------

    $SteamPath = "${env:ProgramFiles(x86)}\Steam"
    $LibraryVdf = Join-Path $SteamPath "steamapps\libraryfolders.vdf"

    if (!(Test-Path $LibraryVdf)) {
        throw "找不到 Steam 遊戲庫資訊。"
    }

    $VdfContent = Get-Content $LibraryVdf -Raw

    $Libraries = [regex]::Matches(
        $VdfContent,
        '"path"\s+"([^"]+)"'
    ) | ForEach-Object {
        $_.Groups[1].Value.Replace("\\", "\")
    }

    $Libraries += $SteamPath

    foreach ($Lib in $Libraries) {

        $PossiblePath = Join-Path `
            $Lib `
            "steamapps\common\ForzaHorizon6"

        if (Test-Path $PossiblePath) {

            $GameRoot = $PossiblePath

            Write-Host "[+] 已找到 FH6"

            break
        }
    }
}

if (!$GameRoot) {
    throw "找不到 Forza Horizon 6。"
}

Write-Host ""
Write-Host "[+] 遊戲路徑："
Write-Host "    $GameRoot"
Write-Host ""
```


# -----------------------------
# 2. 進入 StringTables
# -----------------------------

$StringTablePath = Join-Path `
    $GameRoot `
    "media\Stripped\StringTables"

if (!(Test-Path $StringTablePath)) {
    throw "找不到 StringTables 資料夾：`n$StringTablePath"
}

Set-Location $StringTablePath

Write-Host "[+] 已進入："
Write-Host "    $StringTablePath"
Write-Host ""

# -----------------------------
# 檢查檔案
# -----------------------------

$CHT = "CHT.zip"
$JP  = "JP.zip"
$TMP = "CH.zip"

if (!(Test-Path $CHT)) {
    throw "找不到 CHT.zip"
}

if (!(Test-Path $JP)) {
    throw "找不到 JP.zip"
}

# -----------------------------
# 3. 交換檔名
# -----------------------------

Write-Host "[*] 正在交換語言檔..."

Rename-Item $CHT $TMP -Force
Rename-Item $JP  $CHT -Force
Rename-Item $TMP $JP  -Force

Write-Host "[+] 語言交換完成"
Write-Host ""

# -----------------------------
# 完成
# -----------------------------

Write-Host "========================================"
Write-Host " 完成"
Write-Host "========================================"
Write-Host ""

Write-Host "それでは、良い旅を。"

pause
```
