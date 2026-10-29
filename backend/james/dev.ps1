param()
$NpmArguments = @($args)

$ErrorActionPreference = 'Stop'
$taskVersion = (Get-Content -LiteralPath (Join-Path $PSScriptRoot '.node-version') -Raw).Trim()
$taskRuntime = Join-Path $PSScriptRoot ".tools/node-v$taskVersion-win-x64"
$taskOriginalPath = $env:Path
$taskExitCode = 0

try {
  if (Test-Path -LiteralPath (Join-Path $taskRuntime 'node.exe')) {
    $env:Path = "$taskRuntime;$env:Path"
  }
  $taskActualVersion = & node -p 'process.versions.node'
  if ($LASTEXITCODE -ne 0 -or ([version] $taskActualVersion).Major -ne 24 -or ([version] $taskActualVersion).Minor -lt 15) {
    throw "This backend requires Node 24.15+ (reference: $taskVersion). Install Node 24 or provide its portable runtime in .tools."
  }
  if (-not $NpmArguments) { $NpmArguments = @('run', 'verify') }
  Push-Location -LiteralPath $PSScriptRoot
  try {
    & npm.cmd @NpmArguments
    $taskExitCode = $LASTEXITCODE
  } finally {
    Pop-Location
  }
} finally {
  $env:Path = $taskOriginalPath
}
exit $taskExitCode
