# ============================================================
# Setup Flutter PATH setelah Flutter SDK selesai di-extract
# Jalankan sebagai user biasa (tidak perlu admin)
# ============================================================

$flutterDir = "$env:LOCALAPPDATA\flutter"

if (-not (Test-Path "$flutterDir\bin\flutter.bat")) {
    Write-Host "[ERROR] Flutter belum ada di $flutterDir" -ForegroundColor Red
    Write-Host "Pastikan extraction sudah selesai dulu" -ForegroundColor Yellow
    exit 1
}

# Tambahkan Flutter ke User PATH
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($currentPath -notlike "*$flutterDir\bin*") {
    [Environment]::SetEnvironmentVariable(
        "PATH",
        "$flutterDir\bin;$currentPath",
        "User"
    )
    Write-Host "[OK] Flutter ditambahkan ke PATH user" -ForegroundColor Green
} else {
    Write-Host "[INFO] Flutter sudah ada di PATH" -ForegroundColor Yellow
}

# Set untuk sesi ini juga
$env:PATH = "$flutterDir\bin;$env:PATH"

Write-Host "`nVerifikasi Flutter:" -ForegroundColor Cyan
& "$flutterDir\bin\flutter.bat" --version

Write-Host "`nMenjalankan flutter doctor..." -ForegroundColor Cyan
& "$flutterDir\bin\flutter.bat" doctor
