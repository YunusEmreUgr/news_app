# Domain Katmanı (Domain Layer)

## 📌 Genel Bakış
Domain katmanı, uygulamanın **en saf iş kurallarının (Business Rules)** ve domain modellerinin yer aldığı merkezdir. Dış kütüphanelerden, Flutter UI çerçevesinden veya veritabanı/API bağımlılıklarından **tamamen bağımsızdır**.

## 📁 Klasör Yapısı

```
lib/domain/
├── entities/        # Saf Domain modelleri (UserEntity, TokenEntity)
├── repositories/    # Veri erişim arayüzleri (IAuthRepository)
└── usecases/        # İş kurallarını (Login, Register, Logout) yürüten tek sorumluluk sınıfları
```

## 🛠️ Temel İlkeler ve Kurallar

1. **Dependency Inversion (Bağımlılığın Ters Çevrilmesi):** Domain katmanı Data katmanına bağımlı değildir; aksine Data katmanı Domain katmanındaki soyut `IAuthRepository` arayüzünü implement eder.
2. **Single Responsibility (Tek Sorumluluk):** Her UseCase (örneğin `LoginUseCase`) yalnızca TEK bir iş kuralından sorumludur ve `call(...)` fonksiyonu ile çağrılır.
3. **Immutability (Değişmezlik):** Entity sınıfları immutable (değiştirilemez) yapıda tasarlanır.
