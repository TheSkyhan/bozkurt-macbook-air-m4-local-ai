---
name: apple-gelistirme
description: "macOS ve iOS için Swift/SwiftUI/Xcode projelerini Apple Silicon üzerinde geliştir, derle ve doğrula."
---

# Apple Uygulama Geliştirme

Bu beceriyi iOS, macOS, Swift, SwiftUI veya Xcode görevi için kullan. Önce `xcodebuild -version` ve mevcut proje yapısını kontrol et. Var olan projeyi `xcodebuild -list` ile tanı; şema, hedef ve simülatörü çıktıdan belirle.

- Yeni bir proje için kullanıcı uygulama adı ve hedefi açıkça verdiyse bundle kimliği için bekleme: güvenli, değiştirilebilir `com.example.<UygulamaAdi>` varsayılanını kullan ve sonucu bildir. Uygulama adı veya platform gerçekten belirsizse sor.
- Yeni proje klasörü henüz yokken `xcodebuild -list -project` çalıştırma. Önce klasörü/projeyi oluştur; her `write` veya `bash` ile dosya üretiminden hemen sonra `test -e <tam-yol>` ile gerçekten oluştuğunu doğrula. Doğrulamadan "oluşturuldu" deme.
- Kullanıcı yalnız ilk aşamayı istediyse proje iskeleti, istenen çalışan dikey parça ve derleme dışında özellik ekleme; başarılı derlemeden sonra dur.
- SwiftUI ile yerel Apple tasarım diline uygun, Dynamic Type ve VoiceOver'a dikkat eden, açık/koyu modda iyi görünen ekranlar geliştir.
- Önce küçük, derlenebilir adımlarla ilerle. Uygun olduğunda `xcodebuild build` veya `xcodebuild test` çalıştır ve gerçek hataya göre düzelt.
- İmzalama, Apple hesabı, cihaz yükleme, App Store yayını veya Simulator dışında GUI hareketi kullanıcıdan açık onay gerektirir.
- Kararlar ve çalışan derleme komutunu `AJAN_HAFIZA.md` içine kısa ekle.
