$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$os = Get-CimInstance Win32_OperatingSystem
if ($os.ProductType -ne 1 -or $os.BuildNumber -lt 22000) { throw 'This check requires Windows 11 client.' }
Write-Host "Target: $($os.Caption), build $($os.BuildNumber), $env:PROCESSOR_ARCHITECTURE"
$defender = Get-MpComputerStatus
if (-not $defender.AntivirusEnabled -or -not $defender.RealTimeProtectionEnabled) {
    throw 'Endpoint protection is not active. Test stopped without weakening protection.'
}
Write-Host 'PASS: Microsoft Defender antivirus and real-time protection active'
if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
    # Microsoft's documented prerequisite route; only on this disposable runner.
    Install-PackageProvider -Name NuGet -Force -Scope CurrentUser | Out-Null
    Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery -Scope CurrentUser
    Import-Module Microsoft.WinGet.Client
    Repair-WinGetPackageManager -Force -Latest
}
$winget = (Get-Command winget.exe -ErrorAction Stop).Source
$signature = Get-AuthenticodeSignature -LiteralPath $winget
if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Subject -notmatch 'Microsoft Corporation') {
    throw 'WinGet does not have a valid Microsoft signature.'
}
Write-Host 'PASS: WinGet signature valid and Microsoft publisher verified'
& $winget --version
$ids = @('Google.Chrome','VideoLAN.VLC','7zip.7zip','Zoom.Zoom','Notepad++.Notepad++')
$existing = @()
foreach ($id in $ids) {
    & $winget list --id $id -e --source winget --disable-interactivity --accept-source-agreements | Out-Host
    $rc = $LASTEXITCODE
    if ($rc -eq 0) { $existing += $id }
    elseif ($rc -ne -1978335212) { throw "Cannot establish inventory for $id, code $rc" }
}
$downloads = Join-Path $env:RUNNER_TEMP 'five-apps-verified-downloads'
New-Item -ItemType Directory -Force $downloads | Out-Null
foreach ($id in $ids) {
    $dir = Join-Path $downloads $id
    & $winget show --id $id -e --source winget --disable-interactivity --accept-source-agreements | Out-Host
    if ($LASTEXITCODE -ne 0) { throw "Publisher/source lookup failed for $id" }
    & $winget download --id $id -e --source winget --download-directory $dir --disable-interactivity --accept-package-agreements --accept-source-agreements | Out-Host
    if ($LASTEXITCODE -ne 0) { throw "Verified download failed for $id" }
}
Get-ChildItem $downloads -Recurse -File | Where-Object Extension -in '.exe','.msi','.msix' | ForEach-Object {
    $sig = Get-AuthenticodeSignature -LiteralPath $_.FullName
    $hash = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
    Write-Host "Downloaded artifact: $($_.Name), SHA256=$hash, signature=$($sig.Status), publisher=$($sig.SignerCertificate.Subject)"
    if ($sig.Status -in 'HashMismatch','NotTrusted') { throw 'Downloaded artifact signature is invalid or untrusted.' }
}
Start-MpScan -ScanType CustomScan -ScanPath $downloads
$detections = @(Get-MpThreatDetection | Where-Object { ($_.Resources -join ' ') -like "*$downloads*" })
if ($detections.Count -gt 0) { throw 'Defender reported a detection in test downloads.' }
Write-Host 'PASS: Staged downloads scanned; no matching Defender detection reported. This is not a malware-free guarantee.'
$install = Join-Path $root 'package\Install-5-Apps.bat'
function Run-Package([string]$argument='') {
    & cmd.exe /d /c "`"$install`" $argument < NUL" | Out-Host
    if ($LASTEXITCODE -ne 0) { throw "Package failed for '$argument', code $LASTEXITCODE" }
}
Run-Package '/dryrun'
Run-Package
foreach ($id in $ids) {
    & $winget list --id $id -e --source winget --disable-interactivity --accept-source-agreements | Out-Host
    if ($LASTEXITCODE -ne 0) { throw "Installed app not verified: $id" }
}
$state = Join-Path $env:LOCALAPPDATA 'FiveApps\installed-by-us.txt'
$tracked = if (Test-Path $state) { @(Get-Content $state) } else { @() }
foreach ($id in $existing) { if ($tracked -contains $id) { throw "Pre-existing app incorrectly tracked: $id" } }
Write-Host 'PASS: Five apps inventoried after install; pre-existing apps not claimed'
Run-Package
$after = if (Test-Path $state) { @(Get-Content $state) } else { @() }
if (Compare-Object $tracked $after) { throw 'Rerun changed ownership records.' }
Write-Host 'PASS: Repeated install preserved ownership records'
Run-Package '/undo'
foreach ($id in $existing) {
    & $winget list --id $id -e --source winget --disable-interactivity --accept-source-agreements | Out-Host
    if ($LASTEXITCODE -ne 0) { throw "Undo lost a pre-existing app: $id" }
}
foreach ($id in $tracked) {
    & $winget list --id $id -e --source winget --disable-interactivity --accept-source-agreements | Out-Host
    if ($LASTEXITCODE -ne -1978335212) { throw "Undo did not confirm absence of $id" }
}
Write-Host 'PASS: Real Windows 11 install, rerun and undo completed; pre-existing apps preserved'
Write-Host 'LIMIT: ARM64 runner; no x64 client, interactive UAC, first-launch GUI, offline or low-disk claim.'
