$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$sandbox = Join-Path $env:RUNNER_TEMP ('Five Apps test ' + [guid]::NewGuid())
New-Item -ItemType Directory $sandbox | Out-Null
$env:FIVEAPPS_MOCK_STATE = Join-Path $sandbox 'mock.txt'
$env:LOCALAPPDATA = Join-Path $sandbox 'profile'
New-Item -ItemType Directory $env:LOCALAPPDATA | Out-Null
$source = @'
using System;
using System.IO;
using System.Collections.Generic;
public class MockWinget {
 public static int Main(string[] args) {
  string path = Environment.GetEnvironmentVariable("FIVEAPPS_MOCK_STATE");
  var apps = new HashSet<string>(File.Exists(path) ? File.ReadAllLines(path) : new string[0]);
  string id = "";
  for(int i=0; i<args.Length-1; i++) if(args[i]=="--id") id=args[i+1];
  string mode=Environment.GetEnvironmentVariable("FIVEAPPS_MOCK_MODE");
  if(args[0]=="list") {
   if(mode=="query-error") return 5;
   return apps.Contains(id) ? 0 : unchecked((int)0x8a150014);
  }
  if(args[0]=="install") {
   if(mode=="install-error") return 1;
   apps.Add(id); File.WriteAllLines(path,apps); return 0;
  }
  if(args[0]=="uninstall") {
   if(mode=="undo-error") return 1;
   apps.Remove(id); File.WriteAllLines(path,apps); return 0;
  }
  return 0;
 }
}
'@
# Windows PowerShell compiles a runnable .NET Framework executable.
Add-Type -TypeDefinition $source -OutputAssembly (Join-Path $sandbox 'winget.exe') -OutputType ConsoleApplication
$env:PATH = $sandbox + ';' + $env:PATH
$install = Join-Path $root 'package\Install-5-Apps.bat'
function Run-Installer([string]$arg='') {
 $text = & cmd.exe /d /c "`"$install`" $arg < NUL" 2>&1
 $rc = $LASTEXITCODE
 $text | ForEach-Object { Write-Host $_ }
 Write-Host "Wrapper exit code: $rc"
 return $rc
}
function Assert([bool]$ok, [string]$message) { if(-not $ok) { throw $message }; Write-Host "PASS: $message" }
$output = Run-Installer '/dryrun'
Assert ($output[-1] -eq 0) 'Preview returns success'
Assert (-not (Test-Path (Join-Path $env:LOCALAPPDATA 'FiveApps'))) 'Preview writes no state'
Set-Content $env:FIVEAPPS_MOCK_STATE 'Google.Chrome'
$env:FIVEAPPS_MOCK_MODE='query-error'
$output=Run-Installer
Assert ($output[-1] -eq 1) 'Inventory error fails closed'
Assert ((Get-Content $env:FIVEAPPS_MOCK_STATE).Count -eq 1) 'Inventory error installs nothing'
$env:FIVEAPPS_MOCK_MODE=''
$output=Run-Installer
Assert ($output[-1] -eq 0) 'Install returns success'
$state=Join-Path $env:LOCALAPPDATA 'FiveApps\installed-by-us.txt'
Assert ((Get-Content $state).Count -eq 4) 'Only four new apps tracked'
Assert (-not ((Get-Content $state) -contains 'Google.Chrome')) 'Pre-existing Chrome not tracked'
$before=Get-Content $state -Raw
$output=Run-Installer
Assert ($output[-1] -eq 0) 'Repeat succeeds'
Assert ((Get-Content $state -Raw) -eq $before) 'Repeat adds no duplicate records'
Set-Content $state 'Google.Chrome" & echo INJECTED'
$output=Run-Installer '/undo'
Assert ($output[-1] -eq 1) 'Invalid ledger fails closed before removal'
Assert ((Get-Content $env:FIVEAPPS_MOCK_STATE).Count -eq 5) 'Invalid ledger removes nothing'
Set-Content $state $before.TrimEnd()
$env:FIVEAPPS_MOCK_MODE='undo-error'
$output=Run-Installer '/undo'
Assert ($output[-1] -eq 1) 'Failed undo returns failure'
Assert ((Get-Content $state).Count -eq 4) 'Failed undo retains ownership records'
$env:FIVEAPPS_MOCK_MODE=''
$output=Run-Installer '/undo'
Assert ($output[-1] -eq 0) 'Undo succeeds'
Assert (-not (Test-Path $state)) 'Undo clears completed records'
Assert ((Get-Content $env:FIVEAPPS_MOCK_STATE) -eq 'Google.Chrome') 'Undo preserves pre-existing Chrome'
Write-Host 'All mocked Windows behavior checks passed. Real application installation is a separate check.'

# Expected absence queries return a nonzero native code; all assertions above passed.
exit 0
