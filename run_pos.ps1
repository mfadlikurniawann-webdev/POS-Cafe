# ============================================================
# Setup & Jalankan POS Cafe
# Jalankan SETELAH Flutter dan VS Build Tools terinstall
# ============================================================

$flutterDir = "$env:LOCALAPPDATA\flutter"
$flutter = "$flutterDir\bin\flutter.bat"
$projectDir = $PSScriptRoot

# Cek Flutter
if (-not (Test-Path $flutter)) {
    Write-Host "[ERROR] Flutter tidak ditemukan. Jalankan setup_flutter_path.ps1 dulu" -ForegroundColor Red
    exit 1
}

Set-Location $projectDir

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  KOPI NUSANTARA POS - Setup & Run" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Step 1: Backup pubspec
Write-Host "`n[1/4] Backup pubspec.yaml..." -ForegroundColor Yellow
Copy-Item "pubspec.yaml" "pubspec.yaml.bak" -Force

# Step 2: flutter create untuk buat windows/ directory
Write-Host "[2/4] Membuat platform files Windows..." -ForegroundColor Yellow
& $flutter create . --project-name pos_cafe --platforms=windows --quiet

# Restore pubspec (punya dependensi lengkap)
Copy-Item "pubspec.yaml.bak" "pubspec.yaml" -Force
Write-Host "      pubspec.yaml dipulihkan" -ForegroundColor Green

# Step 3: flutter pub get
Write-Host "[3/4] Menginstall dependencies..." -ForegroundColor Yellow
& $flutter pub get

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] flutter pub get gagal" -ForegroundColor Red
    exit 1
}

# Step 4: Run
Write-Host "[4/4] Menjalankan aplikasi POS..." -ForegroundColor Yellow
Write-Host "      Pastikan schema SQL sudah dijalankan di Neon.tech console!" -ForegroundColor Cyan
& $flutter run -d windows
