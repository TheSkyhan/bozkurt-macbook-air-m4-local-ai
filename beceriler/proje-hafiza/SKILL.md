---
name: proje-hafiza
description: "Uzun süreli kod projelerinde yerel proje hafızasını, Git durumunu ve doğrulama kayıtlarını kısa ve güvenli biçimde yönet."
---

# Proje Hafızası, Sözleşme ve Doğrulama

Bu beceriyi çok adımlı geliştirme, devam eden proje veya sohbet özeti sonrasında kullan. Proje kökündeki `AJAN_HAFIZA.md` dosyasını önce oku; yoksa kısa bir dosya oluştur. Bu dosya konuşma günlüğü değildir, en fazla aşağıdaki başlıklarda güncel durum özetidir:

- Amaç ve çalışma alanı
- Mimari ve önemli kararlar
- Çalışan komutlar / doğrulama sonucu
- Açık işler ve bilinen sorunlar

- Her önemli değişiklikten sonra yalnız doğrulanmış bilgiyi güncelle; anahtar, parola, token, kişisel veri veya uzun araç çıktısı yazma.
- İşe başlamadan önce proje kökünde `AGENTS.md` varsa oku; yoksa proje ilk kez ciddi biçimde geliştiriliyorsa kısa bir `AGENTS.md` oluştur. Var olan dosyayı asla yeniden yazma. Sözleşmeye yalnız doğrulanmış teknoloji yığını, çalıştırma/test komutları, tasarım kuralları ve açıkça istenmeyen işlemler yazılır.
- İşe başlamadan önce `git status --short` ile kullanıcının mevcut değişikliklerini fark et. İlgisiz değişiklikleri silme, değiştirme veya geri alma.
- Küçük hedeflerle ilerle. Her hedef sonunda değişikliğe uygun doğrulama çalıştır: birim test, lint, derleme veya uygulama başlatma. Görsel arayüz değişikliğinde mümkünse çalışan ekranı da denetle. Komut, sonuç ve varsa bilinen başarısızlık net olarak bildirilmeden işi tamamlanmış sayma.
- Bağımlılık/ayar değişikliği, silme/taşıma, veri dönüşümü ya da üçten fazla dosyaya yayılan değişiklik "büyük değişiklik" sayılır. Önce `git status --short` ve `git diff --stat` ile kapsamı açıkla; geri alınabilir yerel dosya yedeği al; kullanıcı istemedikçe commit yapma. Kullanıcı onayı olmadan commit, push, reset veya kullanıcı değişikliklerine müdahale etme.
- Bağlam daralması ardından proje kökü, `AJAN_HAFIZA.md`, mevcut dosyalar ve Git durumundan çalışmayı sürdür. Yeni sohbet açmak zorunlu değildir.
