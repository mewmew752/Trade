# Export XM GOLD# M1 history (with XM's spread per minute) for research, and send it to your Telegram.
# Usage (PowerShell on the VPS):  irm https://raw.githubusercontent.com/mewmew752/Trade/ccr-9e2c76a8-vu39m1/export.ps1 | iex
# - read-only: places no orders; the bot keeps running after MT5 restarts
# - writes MQL5\Files\GOLD_M1_<from>_<to>.csv, copies it to the Desktop and sends it to Telegram (if a token was set up)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$base   = 'https://raw.githubusercontent.com/mewmew752/Trade/ccr-9e2c76a8-vu39m1'
$symbol = if ($env:TRADEFULL_SYMBOL) { $env:TRADEFULL_SYMBOL } else { 'GOLD#' }
$from   = 1767225600   # 2026-01-01 00:00 (server time)

Write-Host '== XauRsiTrend history export ==' -ForegroundColor Cyan

# 1) MetaTrader 5 and its data folder
$proc = Get-Process terminal64 -ErrorAction SilentlyContinue | Select-Object -First 1
if ($proc) { $exe = $proc.Path }
else {
    $exe = Get-ChildItem 'C:\Program Files\*\terminal64.exe', 'C:\Program Files (x86)\*\terminal64.exe' -ErrorAction SilentlyContinue |
           Select-Object -First 1 -ExpandProperty FullName
}
if (-not $exe) { throw 'MetaTrader 5 (terminal64.exe) not found.' }
$installDir = (Split-Path $exe).TrimEnd('\')
$dataDir = $null
Get-ChildItem "$env:APPDATA\MetaQuotes\Terminal\*\origin.txt" -ErrorAction SilentlyContinue | ForEach-Object {
    if ((Get-Content $_.FullName -Raw).Trim().TrimEnd('\') -ieq $installDir) { $dataDir = $_.DirectoryName }
}
if (-not $dataDir) { $dataDir = $installDir }
Write-Host "MT5: $exe"
Write-Host "Data folder: $dataDir"

# 2) Script + inputs
$scripts = Join-Path $dataDir 'MQL5\Scripts\XauRsiTrend'
New-Item -ItemType Directory -Force -Path $scripts | Out-Null
Invoke-WebRequest "$base/XauRsiTrend_ExportHistory.ex5" -OutFile (Join-Path $scripts 'XauRsiTrend_ExportHistory.ex5') -UseBasicParsing
$tokFile = Join-Path $env:APPDATA 'TradeFull\telegram_token.txt'
$token = if (Test-Path $tokFile) { (Get-Content $tokFile -Raw).Trim() } else { '' }
$presets = Join-Path $dataDir 'MQL5\Presets'
New-Item -ItemType Directory -Force -Path $presets | Out-Null
@"
InpFrom=$from
InpTelegramToken=$token
"@ | Set-Content -Path (Join-Path $presets 'XauRsiExport.set') -Encoding ASCII

# 3) Start-up config: run the script once on a GOLD# M1 chart (the bot's own chart is restored from the profile)
$ini = Join-Path $env:TEMP 'xrt_export.ini'
@"
[Charts]
MaxBars=500000
[StartUp]
Script=XauRsiTrend\XauRsiTrend_ExportHistory
ScriptParameters=XauRsiExport.set
Symbol=$symbol
Period=M1
"@ | Set-Content -Path $ini -Encoding ASCII

# 4) Restart MT5 with that config
$files = Join-Path $dataDir 'MQL5\Files'
$started = Get-Date
$running = @(Get-Process terminal64 -ErrorAction SilentlyContinue | Where-Object { $_.Path -ieq $exe })
if ($running.Count -gt 0) {
    Write-Host 'Closing MT5...'
    foreach ($p in $running) { $p.CloseMainWindow() | Out-Null }
    foreach ($p in $running) { if (-not $p.WaitForExit(30000)) { $p.Kill(); $p.WaitForExit(10000) | Out-Null } }
    for ($i = 0; $i -lt 30 -and (Get-Process terminal64 -ErrorAction SilentlyContinue | Where-Object { $_.Path -ieq $exe }); $i++) { Start-Sleep -Seconds 1 }
    Start-Sleep -Seconds 3
}
Start-Process -FilePath $exe -ArgumentList "/config:`"$ini`""

# 5) Wait for the file (history download can take a few minutes)
Write-Host 'Exporting (MT5 downloads the history first; this can take up to 10 minutes)...'
$out = $null
for ($i = 0; $i -lt 120 -and -not $out; $i++) {
    Start-Sleep -Seconds 5
    $out = Get-ChildItem (Join-Path $files 'GOLD*_M1_*.csv') -ErrorAction SilentlyContinue |
           Where-Object { $_.LastWriteTime -gt $started } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
}
if (-not $out) { Write-Host 'No file yet. Check MT5 > Toolbox > Experts for lines starting with XRT_EXPORT.' -ForegroundColor Red; return }
Start-Sleep -Seconds 5
$desk = [Environment]::GetFolderPath('Desktop')
Copy-Item $out.FullName (Join-Path $desk $out.Name) -Force
Write-Host ''
Write-Host "Done: $($out.Name) ($([math]::Round($out.Length / 1MB, 1)) MB) copied to the Desktop." -ForegroundColor Green
if ($token) { Write-Host 'It was also sent to your Telegram bot chat. Forward / upload that file to Claude.' -ForegroundColor Green }
else { Write-Host 'Telegram is not set up: upload the Desktop file to Claude.' -ForegroundColor Yellow }
