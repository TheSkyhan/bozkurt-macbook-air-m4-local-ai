---
name: php-web
description: "PHP ile güvenli ve bakımı kolay web, blog ve gezi rehberi projeleri geliştir; macOS üzerinde test et."
---

# PHP Web Geliştirme

Bu beceriyi yalnızca PHP, blog, web sitesi, veritabanı, form veya API görevi için kullan. Önce proje kökünü, PHP sürümünü ve mevcut bağımlılıkları incele. Yeni bir proje Masaüstünde kullanıcıya anlaşılır isimli ayrı bir klasöre kurulmalıdır.

- PHP kodunda `declare(strict_types=1);`, kaçışlama, CSRF korunumu, sunucu tarafı doğrulama ve PDO hazırlanmış sorgularını uygun yerde kullan.
- Gezi/blog arayüzlerinde sade, mobil uyumlu, erişilebilir HTML; koyu mod ve iyi tipografi tercih et. Tasarımı önce mevcut projenin düzenine uydur.
- Her değişiklikten sonra değişen PHP dosyalarını `php -l` ile doğrula. Test/çalıştırma komutu varsa onu da uygula.
- Gizli anahtarları sürüm kontrolü dışında, ortam değişkenlerinde veya gitignore kapsamındaki `.env` içinde tut; örnek olarak yalnız `.env.example` üret. Gerçek anahtar, yayınlama ve silme için kullanıcı onayı gerekir.
- İş bittiğinde proje kökündeki `AJAN_HAFIZA.md` dosyasına mimari, çalıştırma komutu ve kalan işleri kısa biçimde ekle.
- Çok dosyalı uygulamayı tek yanıtta tasarlayıp yazma. Önce çalışır bir dikey parça (örneğin veri bağlantısı, tek ekran ve tek işlem) kurup doğrula; sonra sıradaki özelliğe geç. Dosyayı değiştirmeden önce oku ve yalnız gereken bölümü düzenle.
