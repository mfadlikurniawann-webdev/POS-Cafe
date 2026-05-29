# Panduan Integrasi Xendit Payment Gateway (Flutter & Backend)

Panduan ini menjelaskan cara menghubungkan sistem Pemesanan Mandiri (*Customer Self-Ordering*) di aplikasi POS Cafe Anda dengan gateway pembayaran **Xendit** secara nyata (menggunakan API resmi).

---

## 1. Persiapan Akun & API Key Xendit

1. **Daftar Akun Xendit**:
   * Kunjungi [Xendit Dashboard](https://dashboard.xendit.co/) dan daftarkan akun bisnis Anda.
   * Untuk pengembangan/testing, pastikan switch di pojok kiri atas berada pada mode **Development** (Sandbox Mode).

2. **Dapatkan API Key**:
   * Buka menu **Settings** -> **Developers** -> **API Keys**.
   * Klik **Generate Secret Key**.
   * Berikan nama key (misal: `Cafe_POS_Key`) dan atur permission:
     * **Invoices**: `Write` (untuk membuat tagihan baru)
     * **Money-in**: `Read` (untuk membaca status transaksi)
   * Salin Secret Key yang dihasilkan (key ini biasanya berawalan `xnd_development_...`). *Simpan dengan aman, jangan ditaruh langsung secara hardcode di aplikasi client Flutter.*

---

## 2. Arsitektur Alur Pembayaran Terbaik

Untuk keamanan, disarankan menggunakan backend perantara (seperti Node.js, Python, atau Serverless Functions) daripada langsung memanggil API Xendit dari Flutter client.

```
┌─────────┐             ┌─────────────┐             ┌─────────┐
│ Flutter │  (Invoice)  │   Backend   │  (Invoice)  │ Xendit  │
│  Client ├────────────►│  Cafe POS   ├────────────►│   API   │
│         │             │  (Express)  │             │         │
│         │◄────────────┤             │◄────────────┤         │
│         │ (Invoice URL│             │(Invoice URL)│         │
└────┬────┘             └──────┬──────┘             └─────────┘
     │                         ▲
     │ (Pay on Web/QRIS)       │ (Webhook callback
     ▼                         │  when paid)
┌────┴────┐                    │
│ Xendit  │────────────────────┘
│ Payment │
│ Page    │
└─────────┘
```

---

## 3. Implementasi Kode Backend (Contoh Node.js / Express)

Instal SDK resmi Xendit di backend Anda:
```bash
npm install xendit-node
```

Berikut adalah contoh fungsi pembuat invoice pembayaran di backend:

```javascript
const Xendit = require('xendit-node');
const x = new Xendit({
  secretKey: 'xnd_development_MASUKKAN_SECRET_KEY_ANDA_DISINI',
});
const { Invoice } = x;
const invoiceSpecificOptions = new Invoice({});

// Endpoint untuk membuat invoice baru
app.post('/api/checkout', async (req, res) => {
  try {
    const { orderNumber, amount, customerName, tableNumber } = req.body;

    const invoice = await invoiceSpecificOptions.createInvoice({
      externalID: orderNumber, // Menyimpan nomor transaksi cafe Anda
      amount: amount,
      payerEmail: 'customer@nusantaracafe.com',
      description: `Pembayaran Kopi Nusantara - Meja ${tableNumber}`,
      shouldSendEmail: true,
      customer: {
        givenNames: customerName,
      },
      // Callback Url saat pembayaran berhasil
      successRedirectURL: 'https://nusantaracafe.com/payment-success',
      failureRedirectURL: 'https://nusantaracafe.com/payment-failed',
      // Metode pembayaran yang diaktifkan (misal: hanya QRIS dan E-Wallet)
      paymentMethods: ['QRIS', 'SHOPEEPAY', 'OVO', 'DANA', 'LINKAJA'],
    });

    // Mengembalikan invoiceUrl (yang didalamnya memuat halaman QRIS dinamis Xendit)
    res.status(200).json({
      invoiceUrl: invoice.invoice_url,
      externalId: invoice.external_id,
      status: invoice.status,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

---

## 4. Menghubungkan Flutter dengan Invoice URL

Setelah API backend Anda mengembalikan `invoiceUrl`, di aplikasi Flutter client Anda tinggal mengarahkan pelanggan untuk membuka tautan tersebut menggunakan package `url_launcher` atau membukanya di dalam WebView Flutter:

1. Tambahkan dependensi `url_launcher` di `pubspec.yaml`:
   ```yaml
   dependencies:
     url_launcher: ^6.3.0
   ```
2. Contoh pemanggilan di Flutter:
   ```dart
   import 'package:url_launcher/url_launcher.dart';

   Future<void> _payWithXendit(String invoiceUrl) async {
     final Uri url = Uri.parse(invoiceUrl);
     if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
       throw Exception('Tidak dapat membuka halaman pembayaran $invoiceUrl');
     }
   }
   ```

---

## 5. Menangani Webhook Pembayaran Sukses (Callback)

Agar database POS Cafe Anda langsung terupdate otomatis saat pelanggan selesai memindai QRIS/membayar:

1. Buat endpoint Webhook di server backend Anda:
   ```javascript
   app.post('/api/xendit-webhook', async (req, res) => {
     // Xendit akan mengirimkan header callback token untuk validasi keamanan
     const callbackToken = req.headers['x-callback-token'];
     if (callbackToken !== 'TOKEN_DARI_DASHBOARD_XENDIT_ANDA') {
       return res.status(403).send('Validasi Webhook Gagal');
     }

     const { external_id, status, payment_method, amount } = req.body;

     if (status === 'PAID') {
       // 1. Cari transaksi di database cafe berdasarkan orderNumber (external_id)
       // 2. Ubah status pesanan menjadi 'completed' atau 'processing'
       // 3. (Opsional) Kirim notifikasi ke printer dapur/barista untuk memproses pesanan
       console.log(`Pesanan ${external_id} LUNAS via ${payment_method}`);
     }

     res.status(200).send('OK');
   });
   ```

2. **Daftarkan Webhook URL Anda di Dashboard Xendit**:
   * Masuk ke **Xendit Dashboard** -> **Settings** -> **Developers** -> **Callbacks**.
   * Pada kolom **Invoice Paid/Expired**, masukkan URL Webhook Server Anda (misal: `https://api.nusantaracafe.com/api/xendit-webhook`).
   * Salin **Callback Verification Token** yang diberikan Xendit untuk memvalidasi request di backend Anda.
