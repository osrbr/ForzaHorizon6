# =========================================================
# Forza Horizon 6 語言交換腳本
# CHT <-> JP
# =========================================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================"
Write-Host " Forza Horizon 6 語言交換腳本"
Write-Host "========================================"
Write-Host ""

# -----------------------------
# 1. 取得執行路徑 (相容 irm | iex 記憶體執行)
# -----------------------------
$ScriptRoot = if ($PSScriptRoot) {
    $PSScriptRoot
} else {
    $PWD.Path # 支援 iex 遠端執行時的當前工作目錄
}

$GameRoot = $null

Write-Host "[*] 檢查腳本資料夾..."

if ($ScriptRoot -and (Test-Path (Join-Path $ScriptRoot "media"))) {
    $GameRoot = $ScriptRoot
    Write-Host "[+] 使用腳本所在資料夾作為遊戲路徑"
}

# -----------------------------
# 2. Steam 搜尋 fallback
# -----------------------------
if (-not $GameRoot) {

    Write-Host "[*] 嘗試從 Steam 搜尋遊戲..."

    $SteamPath = "${env:ProgramFiles(x86)}\Steam"
    $LibraryVdf = Join-Path $SteamPath "steamapps\libraryfolders.vdf"

    if (Test-Path $LibraryVdf) {

        $VdfContent = Get-Content $LibraryVdf -Raw

        $Libraries = [regex]::Matches(
            $VdfContent,
            '"path"\s+"([^"]+)"'
        ) | ForEach-Object {
            $_.Groups[1].Value.Replace("\\", "\")
        }

        $Libraries += $SteamPath

        foreach ($Lib in $Libraries) {

            $Common = Join-Path $Lib "steamapps\common"

            if (Test-Path $Common) {

                $Hit = Get-ChildItem $Common -Directory -ErrorAction SilentlyContinue |
                    Where-Object {
                        $_.Name -match "Forza"
                    } |
                    Select-Object -First 1

                if ($Hit) {
                    $GameRoot = $Hit.FullName
                    break
                }
            }
        }
    }
}

# -----------------------------
# 3. 最終檢查
# -----------------------------
if (-not $GameRoot) {
    Write-Host ""
    Write-Host "找不到 Forza 遊戲資料夾"
    Write-Host "請確認："
    Write-Host "- 是否已安裝遊戲"
    Write-Host "- 是否在 Steam / 正確磁碟"
    Write-Host ""
    pause
    exit
}

Write-Host ""
Write-Host "[+] 遊戲路徑："
Write-Host "    $GameRoot"
Write-Host ""

# -----------------------------
# 4. 進入 StringTables
# -----------------------------
$TargetPath = Join-Path $GameRoot "media\Stripped\StringTables"

if (-not (Test-Path $TargetPath)) {
    Write-Host "找不到 StringTables："
    Write-Host $TargetPath
    pause
    exit
}

# 先切換目錄
Set-Location $TargetPath

Write-Host "[+] 進入 StringTables"
Write-Host ""

# -----------------------------
# 5. 檔案交換邏輯 (修正 Rename-Item 覆寫錯誤)
# -----------------------------
$CHT = "CHT.zip"
$JP  = "JP.zip"
$TMP = "CH.tmp" # 改用 .tmp 避免與現有檔案衝突

if (!(Test-Path $CHT)) {
    throw "找不到 CHT.zip"
}

if (!(Test-Path $JP)) {
    throw "找不到 JP.zip"
}

Write-Host "[*] 正在交換語言檔..."

# 修正：PowerShell 的 Rename-Item 在目標檔案存在時，即使加 -Force 也會失敗。
# 安全的交換三步驟：
Rename-Item -Path $CHT -NewName $TMP -Force

# 將 JP 重新命名為 CHT (此時 CHT 已不存在，可安全改名)
Rename-Item -Path $JP -NewName $CHT -Force

# 將 TMP 重新命名為 JP (此時 JP 已不存在，可安全改名)
Rename-Item -Path $TMP -NewName $JP -Force

Write-Host "[+] 語言交換完成"
Write-Host ""

Write-Host "========================================"
Write-Host " 完成"
Write-Host ""
Write-Host " 日本へ ようこそ"
Write-Host "========================================"
Write-Host ""



pause
