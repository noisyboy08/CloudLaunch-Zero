param(
  [string]$AwsProviderVersion = "5.100.0",
  [string]$ArchiveProviderVersion = "2.7.1"
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = (Resolve-Path (Join-Path $scriptDir "..")).Path
$toolsDir = Join-Path $rootDir ".tools"
$downloadsDir = Join-Path $toolsDir "provider-zips"
$mirrorRoot = Join-Path $rootDir ".providers-mirror"
$mirrorHostRoot = Join-Path $mirrorRoot "registry.terraform.io\hashicorp"
$mirrorConfigFile = Join-Path $toolsDir "terraformrc-mirror.tfrc"

New-Item -ItemType Directory -Path $downloadsDir -Force | Out-Null
New-Item -ItemType Directory -Path $mirrorHostRoot -Force | Out-Null

function Download-ProviderZip {
  param(
    [Parameter(Mandatory = $true)][string]$ProviderName,
    [Parameter(Mandatory = $true)][string]$ProviderVersion
  )

  $zipName = "terraform-provider-$ProviderName" + "_$ProviderVersion" + "_windows_amd64.zip"
  $downloadUrl = "https://releases.hashicorp.com/terraform-provider-$ProviderName/$ProviderVersion/$zipName"
  $zipPath = Join-Path $downloadsDir $zipName

  if (Test-Path $zipPath) {
    Write-Host "Using cached zip: $zipName" -ForegroundColor Yellow
    return $zipPath
  }

  Write-Host "Downloading $zipName ..." -ForegroundColor Cyan
  # curl resume keeps progress on unstable connections.
  curl.exe -4 -L -C - $downloadUrl -o $zipPath
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to download provider zip: $zipName"
  }

  return $zipPath
}

function Install-ProviderToMirror {
  param(
    [Parameter(Mandatory = $true)][string]$ProviderName,
    [Parameter(Mandatory = $true)][string]$ProviderVersion
  )

  $zipPath = Download-ProviderZip -ProviderName $ProviderName -ProviderVersion $ProviderVersion
  $destDir = Join-Path $mirrorHostRoot "$ProviderName\$ProviderVersion\windows_amd64"
  New-Item -ItemType Directory -Path $destDir -Force | Out-Null
  Expand-Archive -Path $zipPath -DestinationPath $destDir -Force

  Write-Host "Installed mirror provider: hashicorp/$ProviderName@$ProviderVersion" -ForegroundColor Green
}

Install-ProviderToMirror -ProviderName "aws" -ProviderVersion $AwsProviderVersion
Install-ProviderToMirror -ProviderName "archive" -ProviderVersion $ArchiveProviderVersion

$mirrorPathForTerraform = $mirrorRoot -replace "\\", "/"
$mirrorConfig = @"
provider_installation {
  filesystem_mirror {
    path = "$mirrorPathForTerraform"
  }
  direct {
    exclude = [
      "registry.terraform.io/hashicorp/aws",
      "registry.terraform.io/hashicorp/archive"
    ]
  }
}
"@

Set-Content -Path $mirrorConfigFile -Value $mirrorConfig -Encoding ascii
Write-Host "Terraform mirror config written to: $mirrorConfigFile" -ForegroundColor Green
Write-Host "You can now run: .\\scripts\\test.ps1" -ForegroundColor Green
