---
name: kod-incelemesi
description: "Değişiklikleri ve kodu profesyonel kod incelemesinden (code review) geçir. Kullanıcı 'incele', 'review yap', 'hata/var mı bak', 'güvenlik/mantık kontrolü', 'PR'ı denetle' dediğinde kullan."
---
# Kod İncelemesi

Bir diff/dosyayı eleştirel gözle incele; övme, sorun bul. Amaç: hatayı kullanıcıya ulaşmadan yakalamak.

## Kontrol listesi
- **Doğruluk:** Beklenen davranışı üretiyor mu? Sınır durumlar (boş, tek eleman, negatif, çok büyük, null/None, Unicode/Türkçe karakter).
- **Güvenlik:** Kullanıcı girdisi SQL komutuna/commuta/komuta enjekte edilebilir mi? Path traversal, XSS, açık sırlar/token, yetkisiz dosya erişimi.
- **Hata yönetimi:** Yakalanmayan istisnalar, yutulan hatalar, sessiz başarısızlıklar. Yalnız sistem sınırlarında doğrulama.
- **Okunabilirlik/bakım:** Tekrar, ölü kod, belirsiz isimler, gereksiz soyutlama, yorum kirliliği.
- **Performans:** Döngü içinde IO, gereksiz bellek kopyası, N+1.
- **Test:** Değişen davranış için test var mı, testler gerçekten bir şey iddia ediyor mu.

## Çıktı biçimi
Önce **özet** (1-2 cümle: genel karar — onay / düzeltme gerek / reddet). Sonra bulguları önem sırasıyla:
- 🔴 Kritik (düzeltmeden verme) · 🟡 Önemli · 🔵 İyileştirme · 🟢 İyi olan kısım
Her bulguda: dosya:satır, sorun, neden, önerilen düzeltme (kısa kod). Soyut "iyi değil" deme; somut göster.
Yalnız inceleme istendiyse rapor ver. Kullanıcı düzeltme de istediyse kapsam içindeki düzeltmeleri uygula ve test et.
