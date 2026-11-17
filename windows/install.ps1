param()

$ErrorActionPreference = 'Stop'

function Test-Administrator {
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = [Security.Principal.WindowsPrincipal]::new($identity)
  return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
  throw 'Run this script from an Administrator PowerShell session to install the required tools.'
}

$source = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$destination = Join-Path $env:LOCALAPPDATA 'nvim'
$marker = Join-Path $destination '.kickstart-modular-windows-install'

if (-not (Get-Command winget -ErrorAction SilentlyContinue) -and -not (Get-Command choco -ErrorAction SilentlyContinue)) {
  throw 'Install Windows Package Manager (winget) or Chocolatey, then run this script again.'
}

if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
  Write-Host 'Installing Chocolatey through Windows Package Manager...'
  winget install --id Chocolatey.Chocolatey --exact --accept-source-agreements --accept-package-agreements
  if ($LASTEXITCODE -ne 0) {
    throw "Chocolatey installation failed with exit code $LASTEXITCODE."
  }

  $chocoPath = Join-Path $env:ProgramData 'chocolatey\bin'
  if (Test-Path $chocoPath) {
    $env:Path = "$chocoPath;$env:Path"
  }
}

if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
  throw 'Chocolatey was installed but choco.exe is not available. Open a new PowerShell session and retry.'
}

Write-Host 'Installing Neovim and configuration dependencies...'
choco install -y neovim git ripgrep wget fd unzip gzip mingw make tree-sitter
if ($LASTEXITCODE -ne 0) {
  throw "Dependency installation failed with exit code $LASTEXITCODE."
}

if ($source.TrimEnd('\') -ne $destination.TrimEnd('\')) {
  if (Test-Path $destination) {
    $previousSource = if (Test-Path $marker) { Get-Content -LiteralPath $marker -Raw } else { $null }
    if ($previousSource -ne $source) {
      $backup = "$destination.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
      Copy-Item -LiteralPath $destination -Destination $backup -Recurse
      Write-Host "Existing Neovim configuration backed up to: $backup"
    }
  }

  New-Item -ItemType Directory -Path $destination -Force | Out-Null
  Get-ChildItem -LiteralPath $source -Force |
    Where-Object { $_.Name -notin @('.git', '.DS_Store', 'windows') } |
    ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination $destination -Recurse -Force }
  Set-Content -LiteralPath $marker -Value $source
}

Write-Host "Neovim config installed at: $destination"
Write-Host 'Restart PowerShell, then run nvim. Plugins will install on first launch.'
