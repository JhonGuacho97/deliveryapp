param()

# Keep native flags such as -d intact; advanced PowerShell parameters would
# otherwise interpret -d as the common -Debug switch.
$FlutterArguments = @($args)

$ErrorActionPreference = 'Stop'
$taskFlutter = Join-Path $PSScriptRoot '.tools/flutter/bin/flutter.bat'
if (-not (Test-Path -LiteralPath $taskFlutter)) {
  $taskFlutter = (Get-Command flutter -ErrorAction Stop).Source
}
$taskExitCode = 0
$env:CI = 'true'
$env:FLUTTER_SUPPRESS_ANALYTICS = 'true'
Push-Location -LiteralPath $PSScriptRoot
try {
  if (-not $FlutterArguments -or $FlutterArguments[0] -eq 'verify') {
    & $taskFlutter pub get --enforce-lockfile
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    & $taskFlutter analyze
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    & $taskFlutter test
  } else {
    & $taskFlutter @FlutterArguments
  }
  $taskExitCode = $LASTEXITCODE
} finally {
  Pop-Location
}
exit $taskExitCode
