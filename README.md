
  
<h2 align="center">🚗 PayPark — Mobil Tabanlı Akıllı Otopark Rezervasyon ve Yönetim Sistemi</h2>


<p align="center">
  PayPark; **paylaşım ekonomisi** yaklaşımıyla kullanıcıların yakındaki otoparkları harita üzerinden keşfedip **rezervasyon oluşturabildiği**, otopark sahiplerinin ise alanlarını sisteme ekleyip **yönetebildiği** bir mobil uygulamadır.
</p>


<p align="center">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-Mobile-blue" />
  <img alt="Node.js" src="https://img.shields.io/badge/Node.js-Backend-green" />
  <img alt="PostgreSQL" src="https://img.shields.io/badge/PostgreSQL-Database-blue" />
  <img alt="JWT" src="https://img.shields.io/badge/Auth-JWT-orange" />
  <img alt="Status" src="https://img.shields.io/badge/Status-Prototype-yellow" />
</p>



<h2 align="center">✨ Özellikler</h2>


### Kullanıcı
- 🗺️ **Harita & Yakındaki Otoparklar:** konuma göre listeleme, **yarıçap (km) ayarı**
- 🧾 **Rezervasyonlar:** **Aktif / Geçmiş / İptal** sekmeleri, rezervasyon oluşturma akışı
- 🅿️ **Park Detayı:** fiyat, konum, açıklama gibi detayları görüntüleme
- 👤 **Profil:** telefon bilgisi, **şifre değiştirme**, otopark sahibi başvurusu
- 💬 **Destek:** **SSS (FAQ)** + **Canlı Destek** arayüzü
- 💳 *(Opsiyonel/Prototype)* **Ödeme Simülasyonu:** demo amaçlı “fake payment” akışı

### Otopark Sahibi
- 🏢 **Owner Panel:** otopark ekleme, otoparklarım, rezervasyon yönetimi
- 📋 **Owner Rezervasyonları:** gelen rezervasyonları görüntüleme (demo/prototype)
  
 
 <h2 align="center">🧰 Kullanılan Teknolojiler</h2>

### Mobil (Frontend)
- **Flutter (Dart)**
- **flutter_map** (harita)
- **geolocator** (konum servisleri / izinler)
- **latlong2** (koordinat & mesafe hesapları)
- **dio** (HTTP istemcisi)
- **intl** (tarih/saat formatlama)
- **flutter_secure_storage** (token/oturum verisini güvenli saklama)
- Custom UI bileşenleri (ör. rezervasyon oluşturma sheet, app bar, keyboard scroll wrapper)

### Backend
- **Node.js + Express**
- **JWT** tabanlı kimlik doğrulama
- REST API mimarisi (ör. `/reservations/me` vb.)

### Veritabanı
- **PostgreSQL**
- **Neon (serverless Postgres)** ile hosted kullanım 

  
 <h2 align="center">📁 Proje Yapısı</h2>

```txt
PayPark/
├── frontend/          # Flutter mobil uygulama
├── backend/           # Node.js backend
├── README.md
└── .gitignore
```

<h2 align="center">⚙️ Kurulum</h2>

### Ön Koşullar
- Flutter SDK (stable)
- Android Studio / SDK veya iOS için Xcode (opsiyonel)
- Node.js (LTS)
- PostgreSQL (lokal veya Neon)

### Repoyu Klonla
```bash
git clone https://github.com/yagmurryilmazz/PayPark.git
cd PayPark
makefile
::contentReference[oaicite:0]{index=0}
```

<h2 align="center">▶️ Çalıştırma</h2>

### Frontend (Flutter)

```bash
cd frontend
flutter pub get
flutter run
```
### Backend
```bash
cd backend
npm install
cp .env.example .env
npm run dev
::contentReference[oaicite:0]{index=0}
```
<h2 align="center">🔐 Ortam Değişkenleri (Backend)</h2>

`backend/.env` dosyası oluşturup aşağıdaki değişkenleri doldurun:

```env
PORT=3000
DATABASE_URL=
JWT_SECRET=
ADMIN_EMAIL=

::contentReference[oaicite:0]{index=0}
```
<h2 align="center">🧪 Kullanım Senaryosu (Kısa)</h2>

1) Kullanıcı haritada konumunu görür, yarıçapı (km) ayarlar  
2) Yakındaki otoparkları listeler ve park detayına gider  
3) Rezervasyon oluşturur, “Rezervasyonlarım” ekranında takip eder  
4) Otopark sahibi panelinden otopark ekler ve rezervasyonları görüntüler  

<h2 align="center">✅ Güvenlik Notları</h2>

- `.env` ve tüm secret’lar **.gitignore** ile dışarıda tutulur.
- Daha önce yanlışlıkla `.env` pushlandıysa: **JWT_SECRET** ve **DATABASE_URL** mutlaka rotate edilmelidir.

<h2 align="center">👥 Ekip</h2>

- Yağmur Burçin Yılmaz  
- Berna Tütüncü  


<h2 align="center">📄 Lisans</h2>

Eğitim amaçlı geliştirilmiştir.





 hiçbir şeyi değiştirmeden sadece ingilizce olduğunu belli ederek sadece metinin dilini değiştiren kodu ver tek blokta ver
