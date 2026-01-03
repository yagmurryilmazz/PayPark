
  
<h2 align="center">🚗 PayPark — Mobil Tabanlı Akıllı Otopark Rezervasyon ve Yönetim Sistemi</h2>


<p align="center">
  PayPark; <b>paylaşım ekonomisi</b> yaklaşımıyla kullanıcıların yakındaki otoparkları harita üzerinden keşfedip <b>rezervasyon oluşturabildiği</b>, otopark sahiplerinin ise alanlarını sisteme ekleyip <b>yönetebildiği</b> bir mobil uygulamadır.
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
- 💳 **Ödeme Simülasyonu:** demo amaçlı “fake payment” akışı

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

```

<h2 align="center">🔐 Ortam Değişkenleri (Backend)</h2>


`backend/.env` dosyası oluşturup aşağıdaki değişkenleri doldurun:

```env
PORT=3000
DATABASE_URL=
JWT_SECRET=
ADMIN_EMAIL=

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



<h2 align="center">🚗 PayPark — Smart Parking Reservation & Management System</h2>


<p align="center">
  PayPark is a mobile application built with a <b>sharing economy</b> approach, where users can discover nearby parking lots on a map and <b>create reservations</b>, while parking owners can add their spaces to the system and <b>manage</b> them.
</p>

<p align="center">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-Mobile-blue" />
  <img alt="Node.js" src="https://img.shields.io/badge/Node.js-Backend-green" />
  <img alt="PostgreSQL" src="https://img.shields.io/badge/PostgreSQL-Database-blue" />
  <img alt="JWT" src="https://img.shields.io/badge/Auth-JWT-orange" />
  <img alt="Status" src="https://img.shields.io/badge/Status-Prototype-yellow" />
</p>


<h2 align="center">✨ Features</h2>


### User
- 🗺️ <b>Map & Nearby Parking Lots:</b> location-based listing, <b>radius (km) adjustment</b>
- 🧾 <b>Reservations:</b> <b>Active / Past / Cancelled</b> tabs, reservation creation flow
- 🅿️ <b>Park Details:</b> view price, location, description, and other details
- 👤 <b>Profile:</b> phone info, <b>change password</b>, parking owner application
- 💬 <b>Support:</b> <b>FAQ</b> + <b>Live Support</b> UI
- 💳 <b>Payment Simulation:</b> demo “fake payment” flow

### Parking Owner
- 🏢 <b>Owner Panel:</b> add parking lot, my parking lots, reservation management
- 📋 <b>Owner Reservations:</b> view incoming reservations (demo/prototype)



<h2 align="center">🧰 Technologies Used</h2>


### Mobile (Frontend)
- <b>Flutter (Dart)</b>
- <b>flutter_map</b> (maps)
- <b>geolocator</b> (location services / permissions)
- <b>latlong2</b> (coordinates & distance calculations)
- <b>dio</b> (HTTP client)
- <b>intl</b> (date/time formatting)
- <b>flutter_secure_storage</b> (secure token/session storage)
- Custom UI components (e.g., reservation create sheet, app bar, keyboard scroll wrapper)

### Backend
- <b>Node.js + Express</b>
- <b>JWT</b>-based authentication
- REST API architecture (e.g., <code>/reservations/me</code>)

### Database
- <b>PostgreSQL</b>
- Hosted usage with <b>Neon (serverless Postgres)</b>


<h2 align="center">📁 Project Structure</h2>


```txt
PayPark/
├── frontend/          # Flutter mobile app
├── backend/           # Node.js backend
├── README.md
└── .gitignore
```



<h2 align="center">⚙️ Setup</h2>


### Prerequisites

-Flutter SDK (stable)

-Android Studio / SDK or Xcode for iOS (optional)

-Node.js (LTS)

-PostgreSQL (local or Neon)

### Clone the Repository
```bash
git clone https://github.com/yagmurryilmazz/PayPark.git
cd PayPark
makefile
```

<h2 align="center">▶️ Run</h2>


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
```


<h2 align="center">🔐 Environment Variables (Backend)</h2>


Create backend/.env and fill in the variables below:
```bash
PORT=
DATABASE_URL=
JWT_SECRET=
ADMIN_EMAIL=
```

<h2 align="center">🧪 Usage Scenario (Brief)</h2>


1.The user views their location on the map and adjusts the radius (km)

2.Nearby parking lots are listed and the user opens park details

3.The user creates a reservation and tracks it under “My Reservations”

4.The parking owner adds a parking lot via the owner panel and views reservations


<h2 align="center">✅ Security Notes</h2>


- .env and all secrets are kept out of version control via <b>.gitignore</b>.

- If .env was accidentally pushed before, make sure to rotate <b>JWT_SECRET</b> and <b>DATABASE_URL</b>.


<h2 align="center">👥 Team</h2>

-Yağmur Burçin Yılmaz

-Berna Tütüncü



<h2 align="center">📄 License</h2>

Developed for educational purposes.
