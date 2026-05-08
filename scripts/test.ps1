param(
  [string]$TerraformVersion = "1.7.5"
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = (Resolve-Path (Join-Path $scriptDir "..")).Path
$environments = @("staging", "production")
$toolsDir = Join-Path $rootDir ".tools"
$terraformDir = Join-Path $toolsDir "terraform\$TerraformVersion"
$terraformExe = Join-Path $terraformDir "terraform.exe"
$mirrorConfigFile = Join-Path $toolsDir "terraformrc-mirror.tfrc"

# Avoid indefinite hangs on poor provider registry connectivity.
$env:TF_REGISTRY_CLIENT_TIMEOUT = "60"
$env:TF_REGISTRY_DISCOVERY_RETRY = "2"
if (Test-Path $mirrorConfigFile) {
  $env:TF_CLI_CONFIG_FILE = $mirrorConfigFile
}

function Ensure-LocalTerraform {
  if (Test-Path $terraformExe) {
    return
  }

  New-Item -ItemType Directory -Path $terraformDir -Force | Out-Null

  $zipPath = Join-Path $terraformDir "terraform_${TerraformVersion}_windows_amd64.zip"
  $downloadUrl = "https://releases.hashicorp.com/terraform/$TerraformVersion/terraform_${TerraformVersion}_windows_amd64.zip"

  Write-Host "Downloading Terraform $TerraformVersion ..." -ForegroundColor Yellow
  Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath

  Expand-Archive -Path $zipPath -DestinationPath $terraformDir -Force
  Remove-Item -Path $zipPath -Force
}

function Invoke-Terraform {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$Arguments
  )

  $localTerraform = Get-Command terraform -ErrorAction SilentlyContinue
  if ($localTerraform) {
    & $localTerraform.Source @Arguments
  } elseif (Get-Command docker -ErrorAction SilentlyContinue) {
    docker run --rm `
      -v "${rootDir}:/workspace" `
      -w /workspace `
      "hashicorp/terraform:${TerraformVersion}" `
      @Arguments
  } else {
    Ensure-LocalTerraform
    & $terraformExe @Arguments
  }

  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}

Write-Host "==> Terraform fmt check" -ForegroundColor Cyan
Invoke-Terraform -Arguments @("-chdir=terraform", "fmt", "-recursive", "-check")

foreach ($env in $environments) {
  Write-Host "==> Terraform init (backend disabled): $env" -ForegroundColor Cyan
  Invoke-Terraform -Arguments @("-chdir=terraform/environments/$env", "init", "-backend=false")

  Write-Host "==> Terraform validate: $env" -ForegroundColor Cyan
  Invoke-Terraform -Arguments @("-chdir=terraform/environments/$env", "validate")
}

Write-Host "All static Terraform checks passed for: $($environments -join ', ')" -ForegroundColor Green
