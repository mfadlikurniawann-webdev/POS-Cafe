# ============================================================
# Install Visual Studio 2022 Build Tools
# JALANKAN SCRIPT INI SEBAGAI ADMINISTRATOR:
#   Klik kanan PowerShell -> "Run as Administrator"
#   lalu jalankan: .\install_vs_buildtools.ps1
# ============================================================

Write-Host "Menginstall Visual Studio 2022 Build Tools..." -ForegroundColor Cyan
Write-Host "Proses ini membutuhkan waktu 15-30 menit" -ForegroundColor Yellow

winget install Microsoft.VisualStudio.2022.BuildTools `
    --override "--wait --passive --add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended" `
    --accept-package-agreements `
    --accept-source-agreements

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n[OK] Visual Studio Build Tools berhasil terinstall!" -ForegroundColor Green
    Write-Host "Silakan restart terminal lalu jalankan: flutter doctor" -ForegroundColor Cyan
} else {
    Write-Host "`n[GAGAL] Exit code: $LASTEXITCODE" -ForegroundColor Red
    Write-Host "Coba install manual dari: https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022" -ForegroundColor Yellow
}
