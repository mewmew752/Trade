# TradeFull one-line installer for XM MetaTrader 5 (Windows)
# Usage (PowerShell):  irm https://raw.githubusercontent.com/mewmew752/Trade/ccr-9e2c76a8-vu39m1/setup.ps1 | iex
# - downloads TradeFull_Scalper.ex5 into MT5's MQL5\Experts folder
# - restarts MT5 with the bot attached to a GOLD# M1 chart and algo trading enabled
# - optional Telegram: set $env:TRADEFULL_TG_TOKEN='<bot token>' before running (remembered for later runs)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$base   = 'https://raw.githubusercontent.com/mewmew752/Trade/ccr-9e2c76a8-vu39m1'
$symbol = if ($env:TRADEFULL_SYMBOL) { $env:TRADEFULL_SYMBOL } else { 'GOLD#' }

Write-Host '== TradeFull installer ==' -ForegroundColor Cyan

# 1) Find MetaTrader 5
$proc = Get-Process terminal64 -ErrorAction SilentlyContinue | Select-Object -First 1
if ($proc) { $exe = $proc.Path }
else {
    $exe = Get-ChildItem 'C:\Program Files\*\terminal64.exe', 'C:\Program Files (x86)\*\terminal64.exe' -ErrorAction SilentlyContinue |
           Select-Object -First 1 -ExpandProperty FullName
}
if (-not $exe) { throw 'MetaTrader 5 (terminal64.exe) not found. Install XM MT5 first.' }
$installDir = (Split-Path $exe).TrimEnd('\')
Write-Host "MT5: $exe"

# 2) Find its data folder (where MQL5\Experts lives)
$dataDir = $null
Get-ChildItem "$env:APPDATA\MetaQuotes\Terminal\*\origin.txt" -ErrorAction SilentlyContinue | ForEach-Object {
    if ((Get-Content $_.FullName -Raw).Trim().TrimEnd('\') -ieq $installDir) { $dataDir = $_.DirectoryName }
}
if (-not $dataDir) { $dataDir = $installDir }   # portable install
$experts = Join-Path $dataDir 'MQL5\Experts'
New-Item -ItemType Directory -Force -Path $experts | Out-Null
Write-Host "Data folder: $dataDir"

# 3) Download the bot
$target = Join-Path $experts 'TradeFull_Scalper.ex5'
Invoke-WebRequest "$base/TradeFull_Scalper.ex5" -OutFile $target -UseBasicParsing
Write-Host "Bot saved: $target" -ForegroundColor Green

# 4) Bot inputs (Telegram token is kept on this machine only)
$cfgDir = Join-Path $env:APPDATA 'TradeFull'
New-Item -ItemType Directory -Force -Path $cfgDir | Out-Null
$tokFile = Join-Path $cfgDir 'telegram_token.txt'
if ($env:TRADEFULL_TG_TOKEN) { Set-Content -Path $tokFile -Value $env:TRADEFULL_TG_TOKEN.Trim() -Encoding ASCII }
$token = if (Test-Path $tokFile) { (Get-Content $tokFile -Raw).Trim() } else { '' }
$presets = Join-Path $dataDir 'MQL5\Presets'
New-Item -ItemType Directory -Force -Path $presets | Out-Null
"InpTelegramToken=$token" | Set-Content -Path (Join-Path $presets 'TradeFull.set') -Encoding ASCII
if ($token) { Write-Host 'Telegram: token set' -ForegroundColor Green } else { Write-Host 'Telegram: not set (optional)' }

# 5) Start-up config: enable algo trading, open GOLD# M1 with the bot attached
$ini = Join-Path $env:TEMP 'tradefull_start.ini'
@"
[Experts]
AllowLiveTrading=1
AllowDllImport=0
Enabled=1
Account=0
Profile=0
[StartUp]
Expert=TradeFull_Scalper
ExpertParameters=TradeFull.set
Symbol=$symbol
Period=M1
"@ | Set-Content -Path $ini -Encoding ASCII

# 6) Restart MT5 with that config
# MT5 runs one instance per install: a running copy would ignore the new config,
# so close every instance of this terminal and wait until it has really exited.
$running = @(Get-Process terminal64 -ErrorAction SilentlyContinue | Where-Object { $_.Path -ieq $exe })
if ($running.Count -gt 0) {
    Write-Host 'Closing MT5...'
    foreach ($p in $running) { $p.CloseMainWindow() | Out-Null }
    foreach ($p in $running) { if (-not $p.WaitForExit(30000)) { $p.Kill(); $p.WaitForExit(10000) | Out-Null } }
    for ($i = 0; $i -lt 30 -and (Get-Process terminal64 -ErrorAction SilentlyContinue | Where-Object { $_.Path -ieq $exe }); $i++) {
        Start-Sleep -Seconds 1
    }
    Start-Sleep -Seconds 3
}
Start-Process -FilePath $exe -ArgumentList "/config:`"$ini`""
Start-Sleep -Seconds 15
if (-not (Get-Process terminal64 -ErrorAction SilentlyContinue | Where-Object { $_.Path -ieq $exe })) {
    Write-Host 'MT5 did not start - please run this command again.' -ForegroundColor Red
}
Write-Host ''
Write-Host "Done. MT5 is starting with TradeFull on $symbol M1." -ForegroundColor Green
Write-Host 'Check: TradeFull panel at the top-left of the chart, and the Algo Trading button is green.'
if ($token) {
    Write-Host ''
    Write-Host 'Telegram: in MT5 open Tools > Options > Expert Advisors, tick "Allow WebRequest for listed URL"' -ForegroundColor Yellow
    Write-Host '          and add https://api.telegram.org  - then send /start to your bot in Telegram.' -ForegroundColor Yellow
}
