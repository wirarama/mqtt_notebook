# Unduh dan pasang Mosquitto secara silent ke folder lokal proyek.
# Dipanggil oleh setup.bat. Hanya langkah instalasi yang meminta hak Administrator.
param(
    [Parameter(Mandatory = $true)][string]$Dest,
    [Parameter(Mandatory = $true)][string]$DownloadDir,
    [string[]]$Versions = @('2.0.22', '2.0.21', '2.0.20', '2.0.18')
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
New-Item -ItemType Directory -Force -Path $DownloadDir | Out-Null

# 1. Unduh installer (coba beberapa versi)
$installer = $null
foreach ($v in $Versions) {
    $file = Join-Path $DownloadDir "mosquitto-$v-install-windows-x64.exe"
    if (Test-Path $file) { $installer = $file; break }
    $url = "https://mosquitto.org/files/binary/win64/mosquitto-$v-install-windows-x64.exe"
    Write-Host "   - mencoba Mosquitto $v ..."
    try {
        Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $file
        $installer = $file
        break
    } catch {
        Remove-Item $file -ErrorAction SilentlyContinue
    }
}
if (-not $installer) {
    Write-Host "   [GAGAL] Installer Mosquitto tidak bisa diunduh."
    exit 1
}

# 2. Skrip yang dijalankan dengan hak Administrator:
#    - install silent ke folder lokal
#    - hapus Windows Service yang dibuat installer, supaya broker hanya jalan
#      dari folder ini lewat start_broker.bat (tidak otomatis jalan saat boot)
$worker = Join-Path $DownloadDir 'mosquitto_elevated.ps1'
$content = @"
`$ErrorActionPreference = 'Continue'
Start-Process -FilePath '$installer' -ArgumentList '/S', '/D=$Dest' -Wait
`$svc = Get-CimInstance Win32_Service -Filter "Name='mosquitto'" -ErrorAction SilentlyContinue
if (`$svc -and `$svc.PathName -like '*$Dest*') {
    Stop-Service -Name mosquitto -Force -ErrorAction SilentlyContinue
    sc.exe delete mosquitto | Out-Null
}
"@
Set-Content -Path $worker -Value $content -Encoding UTF8

Write-Host "   Memasang Mosquitto ke $Dest ..."
try {
    Start-Process -FilePath 'powershell.exe' -Verb RunAs -Wait -WindowStyle Hidden `
        -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$worker`"")
} catch {
    Write-Host "   [GAGAL] Izin Administrator ditolak/dibatalkan."
    exit 1
}
Remove-Item $worker -ErrorAction SilentlyContinue

if (Test-Path (Join-Path $Dest 'mosquitto.exe')) {
    Write-Host "   Mosquitto terpasang."
    exit 0
}
Write-Host "   [GAGAL] mosquitto.exe tidak ditemukan setelah instalasi."
exit 1
