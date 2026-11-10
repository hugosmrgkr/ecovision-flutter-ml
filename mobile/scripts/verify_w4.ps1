# Run from PowerShell on Windows (not WSL). Exit if any check fails.
$ErrorActionPreference = 'Stop'
$flutter = 'E:\dev\flutter\bin\flutter.bat'
if (-not (Test-Path $flutter)) {
  throw "Flutter SDK not found at $flutter. Check its installed location."
}
$mobileDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Push-Location $mobileDir
try {
  Write-Host "Using Flutter: $flutter"
  & $flutter --version
  if ($LASTEXITCODE -ne 0) { throw 'flutter --version failed.' }
  & $flutter pub get
  if ($LASTEXITCODE -ne 0) { throw 'flutter pub get failed.' }
  & $flutter analyze
  if ($LASTEXITCODE -ne 0) { throw 'flutter analyze failed.' }
  & $flutter test
  if ($LASTEXITCODE -ne 0) { throw 'flutter test failed.' }
  Write-Host 'W4 automated checks PASSED. Android manual checks are still required.' -ForegroundColor Green
} finally {
  Pop-Location
}
