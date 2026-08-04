# Data Katmanı (Data Layer)

## 📌 Genel Bakış
Data katmanı, dış dünyadan (REST API, local database, secure storage) veri alma ve dış dünyaya veri gönderme sorumluluğunu taşır. DTO (Data Transfer Object) / Model sınıfları ve Repository somut implementasyonları bu katmanda yer alır.

## 📁 Klasör Yapısı

```
lib/data/
├── datasources/     # Remote HTTP ve Local Storage veri kaynakları
├── models/          # API JSON serialization/deserialization DTO sınıfları (Auth, Common)
└── repositories/    # Domain katmanındaki IAuthRepository soyutlamasının somut implementasyonu
```

## 🛠️ Temel İlkeler ve Kurallar

1. **Model & Entity Ayrımı:** API'den dönen JSON nesneleri Data katmanında `Model` (örn: `UserModel`, `TokenModel`) olarak tanımlanır. `toEntity()` metodu ile Domain katmanındaki `Entity` nesnelerine dönüştürülür. UI kesinlikle Data modellerine bağımlı olmamalıdır.
2. **Hata Yönetimi:** Remote DataSource'larda fırlatılan `ApiException`'lar, Repository katmanında yakalanarak Domain katmanının anlayacağı `Failure` nesnelerine (`ServerFailure`, `UnauthorizedFailure`) sarmallanır ve `ApiResult<T>` olarak döndürülür.
