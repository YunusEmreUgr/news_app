# Core Katmanı (Core Layer)

## 📌 Genel Bakış
Core katmanı, uygulamanın tüm diğer katmanları (Data, Domain, Presentation) tarafından ortaklaşa kullanılan, projenin **çekirdek altyapı bileşenlerini** içerir. İş kurallarına doğrudan bağımlı değildir, modüler ve yeniden kullanılabilir niteliktedir.

## 📁 Klasör Yapısı ve Sorumluluklar

```
lib/core/
├── constants/       # API URL'leri, endpoint tanımları, genel uygulama sabitleri
├── errors/          # Custom Exception sınıfları, Failure ve Error handling yapıları
├── init/            # Dependency Injection (GetIt) ve App Initialization başlatıcıları
├── network/         # Dio HTTP Client, Interceptor'lar (Silent Token Refresh Queue)
├── storage/         # Secure Storage (Encrypted Token) ve SharedPreferences işlemleri
├── theme/           # Design Tokens (Colors, Typography, Spacing) & Dynamic Theme Provider
└── widgets/         # Atomic UI Bileşenleri (Custom Button, Input Field, Card, Toast vb.)
```

## 🛠️ Temel İlkeler ve Kurallar

1. **Bağımlılık Yönü:** Core katmanı, `domain`, `data` veya `presentation` katmanlarına BAĞIMLI OLMAMALIDIR. 
2. **401 Silent Token Refresh Pattern:**
   - `auth_interceptor.dart` içerisinde 401 Unauthorized hatası yakalandığında token yenileme isteği dondurularak kuyruğa alınır (`_requestQueue`).
   - Token başarıyla yenilendiğinde kuyruktaki tüm istekler yeni Access Token ile otomatik olarak tekrarlanır (Retry).
   - Yenileme başarısız olduğunda güvenli bir şekilde `onLogout` tetiklenerek kullanıcı giriş ekranına yönlendirilir.
3. **Design Tokens:**
   - `app_colors.dart` ve `app_theme.dart` haricinde UI içerisinde static/hardcoded renk (örn: `Colors.blue`) kullanımından kaçınılmalıdır. Tüm renk ve stil tanımları temadan çekilmelidir (`Theme.of(context)`).
