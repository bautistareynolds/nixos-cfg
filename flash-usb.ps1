# Writes the NixOS ISO raw onto the Kingston DataTraveler USB stick.
# Must run elevated. Refuses to touch anything that isn't a ~29 GB USB Kingston disk.
param(
    [string]$Iso = "$PSScriptRoot\iso\nixos.iso"
)
$ErrorActionPreference = 'Stop'

$disk = Get-Disk | Where-Object { $_.BusType -eq 'USB' -and $_.FriendlyName -like '*Kingston DataTraveler*' }
if (@($disk).Count -ne 1) { throw "Expected exactly one Kingston DataTraveler USB disk, found $(@($disk).Count)." }
if ($disk.IsBoot -or $disk.IsSystem) { throw "Target disk is a boot/system disk. Aborting." }
$sizeGB = $disk.Size / 1GB
if ($sizeGB -lt 20 -or $sizeGB -gt 40) { throw "Unexpected disk size ($sizeGB GB). Aborting." }
if (-not (Test-Path $Iso)) { throw "ISO not found: $Iso" }

Write-Host "Target: Disk $($disk.Number) - $($disk.FriendlyName) - $([math]::Round($sizeGB,1)) GB" -ForegroundColor Yellow
Write-Host "ISO:    $Iso"
$answer = Read-Host "This ERASES that USB stick. Type YES to continue"
if ($answer -ne 'YES') { Write-Host 'Cancelled.'; exit 1 }

Write-Host 'Wiping partition table...'
Clear-Disk -Number $disk.Number -RemoveData -RemoveOEM -Confirm:$false
Start-Sleep -Seconds 2

$src = [System.IO.File]::OpenRead($Iso)
$dst = New-Object System.IO.FileStream("\\.\PhysicalDrive$($disk.Number)", [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::ReadWrite, 4MB, [System.IO.FileOptions]::WriteThrough)
try {
    $buf = New-Object byte[] (4MB)
    $total = $src.Length; $done = 0
    while (($n = $src.Read($buf, 0, $buf.Length)) -gt 0) {
        if ($n % 512 -ne 0) {  # pad final chunk to sector size
            $pad = 512 - ($n % 512); [Array]::Clear($buf, $n, $pad); $n += $pad
        }
        $dst.Write($buf, 0, $n)
        $done += $n
        Write-Progress -Activity 'Writing NixOS ISO to USB' -Status "$([math]::Round($done/1MB)) / $([math]::Round($total/1MB)) MB" -PercentComplete ([math]::Min(100, $done * 100 / $total))
    }
    $dst.Flush()
} finally { $src.Close(); $dst.Close() }

Write-Host 'Done. Safely eject the USB stick (Windows may say it needs formatting - ignore that, do NOT format it).' -ForegroundColor Green
Read-Host 'Press Enter to close'
