# Hentikan broker Mosquitto, Jupyter Lab (beserta kernel), dan jendela CMD
# start_*.bat yang berasal dari folder proyek ini saja.
param([Parameter(Mandatory = $true)][string]$Root)

$root    = (Resolve-Path -LiteralPath $Root).Path.TrimEnd('\').ToLower()
$pyDir   = "$root\python\"
$mqDir   = "$root\mosquitto\"
$procs   = Get-CimInstance Win32_Process

function Stop-Tree([int]$ProcessId) {
    & taskkill.exe /PID $ProcessId /T /F 2>&1 | Out-Null
}

$count = 0

# 1. Jendela CMD dari start_all.bat / start_broker.bat / start_jupyter.bat
#    (taskkill /T ikut menghentikan mosquitto.exe / python.exe di dalamnya)
foreach ($p in $procs | Where-Object { $_.Name -eq 'cmd.exe' -and $_.CommandLine }) {
    $cl = $p.CommandLine.ToLower()
    foreach ($bat in 'start_all.bat', 'start_broker.bat', 'start_jupyter.bat') {
        if ($cl.Contains("$root\$bat")) {
            Write-Host "   - menutup jendela $bat (PID $($p.ProcessId))"
            Stop-Tree $p.ProcessId
            $count++
            break
        }
    }
}

# 2. Sisa proses dari folder python\ dan mosquitto\ (mis. dijalankan manual)
Start-Sleep -Milliseconds 500
foreach ($p in Get-CimInstance Win32_Process | Where-Object { $_.ExecutablePath }) {
    $exe = $p.ExecutablePath.ToLower()
    if ($exe.StartsWith($mqDir) -or $exe.StartsWith($pyDir)) {
        Write-Host "   - menghentikan $($p.Name) (PID $($p.ProcessId))"
        Stop-Tree $p.ProcessId
        $count++
    }
}

if ($count -eq 0) {
    Write-Host "   Tidak ada broker / Jupyter dari folder ini yang sedang berjalan."
} else {
    Write-Host ""
    Write-Host "   [SELESAI] Broker MQTT dan Jupyter Lab sudah dihentikan."
}
