# POS Cafe - Setup Guide

## Prasyarat

1. **Install Flutter SDK** dari https://docs.flutter.dev/get-started/install/windows
2. Tambahkan Flutter ke PATH sistem
3. Jalankan `flutter doctor` untuk verifikasi instalasi

## Langkah Setup

### 1. Inisialisasi Database (Neon.tech)

Buka file `sql/schema.sql` dan jalankan di Neon.tech console:
- Login ke https://console.neon.tech
- Buka project Anda
- Klik "SQL Editor"
- Copy-paste isi `sql/schema.sql` dan eksekusi

### 2. Inisialisasi Flutter Project

```bash
cd D:\Project_NgodingLagi\POS-Cafe

# Buat platform-specific files (Windows desktop)
flutter create . --project-name pos_cafe --platforms=windows

# Install dependencies
flutter pub get
```

### 3. Jalankan Aplikasi

```bash
# Untuk Windows Desktop (direkomendasikan untuk POS)
flutter run -d windows

# Untuk Web (alternatif)
flutter run -d chrome
```

## Struktur Project

```
lib/
├── main.dart                          # Entry point
├── core/
│   ├── config/app_config.dart         # Konfigurasi DB & app
│   ├── theme/app_theme.dart           # Tema & warna
│   └── utils/currency_formatter.dart  # Format Rupiah
├── data/
│   ├── models/                        # Data models
│   ├── services/database_service.dart # Koneksi PostgreSQL
│   └── repositories/                 # Database queries
├── providers/                         # State management
│   ├── pos_provider.dart              # Logika kasir & cart
│   ├── menu_provider.dart             # Manajemen produk
│   └── order_provider.dart           # Riwayat & laporan
└── presentation/
    ├── screens/                       # Halaman-halaman
    └── widgets/                       # Komponen reusable
```

## Fitur

- **Kasir (POS)**: Pilih menu, kelola cart, proses pembayaran (Tunai/Kartu/QRIS/Transfer)
- **Dashboard**: Statistik hari ini, grafik penjualan mingguan, produk terlaris  
- **Manajemen Menu**: CRUD produk, toggle ketersediaan
- **Riwayat Pesanan**: Lihat semua transaksi dengan detail
- **Laporan**: Grafik penjualan bulanan, distribusi produk

## Database

Connection String:
```
postgresql://neondb_owner:***@ep-royal-surf-aopa38s3-pooler.c-2.ap-southeast-1.aws.neon.tech/neondb?sslmode=require
```

Konfigurasi ada di: `lib/core/config/app_config.dart`
