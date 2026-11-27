# MediaHub

MediaHub adalah aplikasi multimedia berbasis Flutter untuk Android. Aplikasi ini menggabungkan katalog audio/video lokal, pemutar media, pemindaian media pada perangkat, serta pengelolaan metadata bersama melalui Cloud Firestore.

## Daftar isi

- [Fitur](#fitur)
- [Teknologi](#teknologi)
- [Struktur proyek](#struktur-proyek)
- [Aset aplikasi](#aset-aplikasi)
- [Firebase dan struktur data](#firebase-dan-struktur-data)
- [Persyaratan](#persyaratan)
- [Menjalankan aplikasi](#menjalankan-aplikasi)
- [Izin Android](#izin-android)
- [Batasan dan catatan](#batasan-dan-catatan)
- [Dokumentasi dan lisensi](#dokumentasi-dan-lisensi)

## Fitur

| Bagian | Fungsi |
|---|---|
| Home | Beranda MediaHub, ringkasan katalog, status inisialisasi Firebase, dan pintasan ke fitur utama serta CRUD Users. |
| Audio | Memutar lagu dari aset aplikasi, memindai audio di perangkat, dan membuka pemutar audio network dari URL HTTPS langsung. |
| Video | Memutar video YouTube dengan pemutar khusus, video MP4 bundel, dan video yang dipindai dari perangkat. URL YouTube lain dapat dimasukkan melalui halaman khusus. |
| Library | Menampilkan katalog media bundel dan membuka Cloud Library untuk mengelola metadata koleksi `songs` di Firestore. |
| Search | Mencari judul, kreator, atau kategori pada katalog media bundel aplikasi. |
| CRUD Users | Membaca, menambah, mengubah, dan menghapus data kelas pada koleksi root `users`. Fitur ini terpisah dari Cloud Library dan bukan pengelolaan akun Firebase. |
| Profile | Menampilkan informasi pengembang serta tautan ke profil sosial. |

Daftar media bundel dapat digunakan tanpa koneksi internet. Media network dan YouTube memerlukan koneksi internet. Metadata Firestore tidak mengunggah atau mengunduh berkas audio/video.

## Teknologi

| Teknologi atau package | Peran |
|---|---|
| Flutter dan Dart | Antarmuka Material 3, navigasi, formulir, dan logika aplikasi. |
| `firebase_core` | Inisialisasi Firebase pada aplikasi. |
| `cloud_firestore` | Penyimpanan metadata Cloud Library dan data Users. |
| `just_audio` | Pemutaran audio dari aset, URL langsung, dan URI media perangkat. |
| `video_player` | Pemutaran video dari aset, URL langsung, dan URI media perangkat. |
| `youtube_player_flutter` | Pemutaran video YouTube melalui player khusus. |
| `photo_manager` | Pemindaian audio/video lokal di Android. |
| `url_launcher` | Membuka tautan eksternal pada halaman Profile. |
| `font_awesome_flutter` | Ikon platform sosial. |

Firebase Authentication tidak digunakan. Firebase Storage juga belum diintegrasikan.

## Struktur proyek

```text
lib/
├── audio/       # Halaman audio dan input URL audio network
├── home/        # Beranda dan pintasan fitur
├── library/     # Library lokal dan Cloud Library
├── media/       # Model, katalog, repository, formulir, dan navigasi media
├── player/      # Pemutar audio, video, dan YouTube
├── profile/     # Informasi pengembang dan tautan sosial
├── search/      # Pencarian katalog bundel
├── users/       # CRUD data Users Firestore
├── video/       # Halaman video
└── main.dart    # Inisialisasi Firebase, tema, dan navigasi utama

assets/
├── images/      # Logo dan gambar profil
├── music/       # Lagu MP3 bundel
└── video/       # Video MP4 bundel

android/         # Konfigurasi aplikasi Android dan Firebase
docs/            # Rules, PRD, dokumentasi implementasi, dan laporan proyek
```

## Aset aplikasi

Katalog audio bundel memuat lagu Hearts2Hearts berikut:

- `assets/music/Hearts2Hearts_-_FOCUS.mp3`
- `assets/music/Hearts2Hearts_-_Lemon_Tang.mp3`
- `assets/music/Hearts2Hearts_-_RUDE.mp3`
- `assets/music/Hearts2Hearts_-_Style.mp3`
- `assets/music/Hearts2Hearts_-_The_Chase.mp3`

Video bundel yang tercatat di katalog adalah `assets/video/rude_mv.mp4`. Aset gambar pengembang berada di `assets/images/`, termasuk logo aplikasi dan `profile.jpeg`.

Informasi hak penggunaan aset pihak ketiga dicatat di [LICENSES.md](LICENSES.md). Pastikan hak distribusi setiap berkas media sesuai sebelum membagikan aplikasi atau repository.

## Firebase dan struktur data

### Konfigurasi aplikasi

Aplikasi Android menggunakan Firebase project `mediahubs-bbf06` dan application ID `com.mediahubs.uts0035`. Berkas konfigurasi Android berada di `android/app/google-services.json`. Koneksi Firestore dan alur CRUD telah berhasil menurut konfirmasi pemilik project.

Untuk menyiapkan project Firebase baru atau memasang ulang konfigurasi:

1. Daftarkan aplikasi Android dengan application ID `com.mediahubs.uts0035` pada Firebase project yang dipilih.
2. Letakkan `google-services.json` yang sesuai di `android/app/`.
3. Aktifkan Cloud Firestore dan gunakan database yang dituju aplikasi.
4. Tinjau lalu terapkan Rules dari [`docs/firestore.rules.example`](docs/firestore.rules.example) melalui Firebase Console.
5. Jalankan aplikasi setelah koneksi dan akses database tersedia.

### Koleksi Firestore

Cloud Library membaca dan menulis metadata pada koleksi root `songs`.

| Field | Tipe | Ketentuan |
|---|---|---|
| `title` | String | Wajib; judul media. |
| `creator` | String | Wajib; kreator atau artis. |
| `type` | String | Wajib; `audio` atau `video`. |
| `sourceType` | String | Wajib; `network` atau `asset` untuk dokumen Cloud Library. |
| `mediaUrl` | String | Wajib; URL HTTPS atau path di bawah `assets/`. |
| `description` | String | Opsional. |
| `category` | String | Opsional. |
| `thumbnailUrl` | String | Opsional. |
| `createdAt` | Timestamp | Wajib; waktu pembuatan. |
| `updatedAt` | Timestamp | Wajib; waktu perubahan terakhir. |

Koleksi root `users` digunakan fitur CRUD Users. Nama field yang dipakai aplikasi adalah **`nama`**, bukan `name`.

| Field | Tipe | Ketentuan |
|---|---|---|
| `nama` | String | Wajib; nama pengguna/mahasiswa. |
| `email` | String | Wajib. |
| `kelas` | String | Wajib. |
| `createdAt` | Timestamp | Wajib; waktu pembuatan. |
| `updatedAt` | Timestamp | Wajib; waktu perubahan terakhir. |

Kedua koleksi menerima field tambahan untuk mendukung perubahan aplikasi berikutnya. Parser list Users menandai `nama`, `email`, atau `kelas` yang hilang, kosong, atau bukan string, sehingga satu dokumen bermasalah tidak menyembunyikan seluruh daftar.

Koleksi root `playlist` juga memiliki Rules publik, tetapi belum memiliki antarmuka atau schema data di aplikasi.

### Akses dan keamanan

Firestore digunakan tanpa login. Rules saat ini mengizinkan client membaca, menambah, mengubah, dan menghapus data pada `songs`, `users`, dan `playlist`. Validasi field inti berlaku pada `songs` dan `users`; `playlist` belum divalidasi. Karena akses bersifat publik, client lain juga dapat menulis field tambahan. Jangan menyimpan informasi rahasia atau data pribadi pada koleksi tersebut.

Rules yang ada di repository adalah berkas contoh lokal. Perubahan Rules di repository tidak otomatis diterapkan ke Firebase Console; terapkan Rules tersebut pada project Firebase yang digunakan.

## Persyaratan

- Flutter SDK dengan Dart yang memenuhi batasan `^3.13.5` pada `pubspec.yaml`.
- Android SDK melalui Android Studio atau instalasi Android SDK yang tersedia.
- Emulator Android atau perangkat Android fisik.
- Firebase project dan database Cloud Firestore untuk fitur cloud.

## Menjalankan aplikasi

Dari direktori root project, ambil dependency dan jalankan aplikasi pada perangkat Android:

```sh
flutter pub get
flutter devices
flutter run -d <android-device-id>
```

Untuk membuat APK release:

```sh
flutter build apk --release
```

APK hasil build berada di `build/app/outputs/flutter-apk/app-release.apk`. Application ID Android adalah `com.mediahubs.uts0035`.

## Izin Android

Aplikasi meminta izin baca media sesuai kategori saat pengguna membuka halaman Audio atau Video. Android versi baru menggunakan `READ_MEDIA_AUDIO` dan `READ_MEDIA_VIDEO`; versi yang lebih lama dapat menggunakan izin penyimpanan yang sesuai dengan versi OS.

Aplikasi memindai MediaStore untuk menampilkan media pada perangkat. Berkas asli tidak disalin, dihapus, atau diunggah ke Firestore maupun Firebase Storage.

## Batasan dan catatan

- Pencarian saat ini mencakup katalog bundel berdasarkan judul, kreator, dan kategori; hasil Cloud Library tidak digabungkan ke pencarian.
- Audio network menerima URL HTTPS langsung menuju berkas audio atau stream yang kompatibel. Tautan halaman YouTube bukan URL audio langsung.
- Pemutaran YouTube memerlukan internet dan bergantung pada izin embedding dari pemilik video.
- File audio/video tersimpan sebagai aset aplikasi atau berada pada sumber network asal. Aplikasi tidak menyediakan unggah media ke Firebase Storage.
- `playlist` belum mempunyai halaman CRUD dan aturan validasi dokumen khusus.
- Akses Firestore tanpa Auth bersifat bersama untuk semua client yang menggunakan Firebase project tersebut.

## Pengembang

- **Nama:** Muhammad Alif Mafaza
- **NIM:** 23.230.0035
- **Program studi:** Sistem Informasi (Bisnis Digital)
- **Mata kuliah:** Pemrograman Berbasis Mobile 2

## Dokumentasi dan lisensi

- [PRD MediaHub](docs/PRD.md) — kebutuhan dan rancangan produk.
- [Dokumentasi implementasi](docs/IMPLEMENTATION.md) — struktur dan keputusan implementasi.
- [Contoh Firestore Rules](docs/firestore.rules.example) — aturan akses koleksi cloud.
- [Daftar lisensi aset](LICENSES.md) — catatan lisensi dependency dan media.
- [Laporan proyek PDF](docs/Dokumentasi_Proyek_MediaHub.pdf) dan [sumber HTML](docs/Dokumentasi_Proyek_MediaHub.html).
