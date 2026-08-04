# 🚀 Kurumsal Flutter Frontend Template

Bu şablon, kurumsal seviyede yüksek performanslı, sürdürülebilir, modüler ve güvenli mobil/web uygulamaları geliştirmek üzere **Clean Architecture** prensiplerine tam uygun olarak tasarlanmıştır. `.NET Backend Template` mimarimiz ile %100 entegredir.

---

## 🏗️ Mimari Yapı (Clean Architecture)

Proje 4 ana katmandan ve modüler klasör yapısından oluşmaktadır:

```
lib/
├── core/                # Çekirdek altyapı, network, storage, tema ve atomic widget'lar
│   ├── constants/       # API URL ve endpoint sabitleri
│   ├── errors/          # Custom Exception ve Failure sarmallayıcıları
│   ├── init/            # AppInitializer ve ServiceLocator (GetIt)
│   ├── network/         # DioClient & 401 Silent Token Refresh Queue Interceptor
│   ├── storage/         # Secure Storage (JWT tokens) ve SharedPreferences
│   ├── theme/           # Design Tokens (Colors, Typography) & Dynamic Theme Provider
│   ├── widgets/         # Atomic UI Bileşenleri (CustomButton, CustomTextField, Card vb.)
│   └── layer.md         # Core katmanı detaylı mimari dokümanı
│
├── data/                # Dış dünya veri erişim katmanı (Data Layer)
│   ├── datasources/     # Remote HTTP ve Local Storage kaynakları
│   ├── models/          # JSON Serialization / Deserialization DTO nesneleri
│   ├── repositories/    # IAuthRepository somut implementasyonları
│   └── layer.md         # Data katmanı detaylı mimari dokümanı
│
├── domain/              # Saf İş Kuralları Katmanı (Domain Layer)
│   ├── entities/        # Saf Domain modelleri (UserEntity, TokenEntity)
│   ├── repositories/    # Soyut veritabanı / API arayüzleri
│   ├── usecases/        # İş kurallarını yürüten tek sorumluluk sınıfları
│   └── layer.md         # Domain katmanı detaylı mimari dokümanı
│
└── presentation/        # Kullanıcı Arayüzü ve State Katmanı (Presentation Layer)
    ├── features/        # Ekranlar (Splash, Login, Register, Dashboard, Settings, Profile)
    ├── navigation/      # Rotalar (AppRouter) ve Route Guard'lar
    ├── providers/       # State Management (AuthProvider)
    └── layer.md         # Presentation katmanı detaylı mimari dokümanı
```

---

## ⚡ Öne Çıkan Kurumsal Özellikler

1. **401 Silent Token Refresh & Concurrency Queue (Interceptor):**
   - Access token süresi dolduğunda gelen ilk 401 yanıtında otomatik olarak `refresh token` isteği tetiklenir.
   - Refresh işlemi devam ederken gelen diğer 401 istekleri dondurularak kuyruğa (`_requestQueue`) alınır.
   - Yeni token alındığında tüm kuyruktaki istekler otomatik olarak yeni token ile tekrarlanır (Retry).
2. **Backend Structured Error Response Entegrasyonu:**
   - Backend'den dönen `{ success: false, error: { code, message, details } }` yapıları istemci tarafında `ApiException` olarak ele alınır ve UI katmanına `Failure` nesneleri olarak iletilir.
3. **Dinamik Design Tokens & Tema Sistemi:**
   - Dark/Light mod arasında dinamik geçiş `ThemeProvider` üzerinden sağlanır ve tercihler `CacheStorage` üzerinde saklanır.
4. **Dependency Injection (GetIt):**
   - Tüm UseCase, Repository, DataSource ve Network client'ları `ServiceLocator` ile yönetilir.

---

## 🛠️ Kurulum ve Çalıştırma

### Bağımlılıkları Yükleme
```bash
flutter pub get
```

### Static Analysis Kontrolü
```bash
flutter analyze
```

### Birim Testleri Çalıştırma
```bash
flutter test
```

### Uygulamayı Başlatma
```bash
flutter run
```
