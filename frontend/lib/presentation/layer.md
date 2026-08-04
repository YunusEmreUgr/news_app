# Presentation Katmanı (Presentation Layer)

## 📌 Genel Bakış
Presentation katmanı, kullanıcı arayüzünü (UI Screens & Atomic Widgets) ve UI durum yönetimini (State Management) barındırır. Bu katmanda iş kuralı (business logic) YAZILMAZ; tüm işlemler `domain` UseCase'lerine delege edilir.

## 📁 Klasör Yapısı

```
lib/presentation/
├── features/        # Ekranlar (Feature-based: Splash, Auth, Dashboard, Settings, Profile)
├── navigation/      # Rotalar, AppRouter ve Route Guard'lar
└── providers/       # ChangeNotifier / State Management sınıfları (AuthProvider vb.)
```

## 🛠️ Temel İlkeler ve Kurallar

1. **State Management:** Provider / ChangeNotifier kullanılır. UI bileşenleri yalnızca state'i dinler ve reaktif olarak güncellenir (`context.watch<AuthProvider>()` veya `Consumer`).
2. **Clean UI & Reusability:** Sayfalarda uzun spagetti kodlar yazmak yerine `core/widgets` altındaki Atomic widget'lar ve küçük özel widget'lar parçalanır.
3. **Route Guards:** Yetkisiz kullanıcıların korumalı sayfalara (`/dashboard`, `/profile`) girmesini önlemek için `AuthProvider.isAuthenticated` kontrolü yapılır.
