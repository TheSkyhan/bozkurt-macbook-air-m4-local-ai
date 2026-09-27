---
name: tasarim-ui
description: "Modern, erişilebilir ve duyarlı web arayüzü/tasarımı üret (HTML/CSS/JS, landing page, dashboard, bileşen, tema). Kullanıcı 'tasarla', 'bir sayfa/ekran yap', 'UI', 'dashboard', 'güzel görünsün', 'marka rengi' gibi bir şey söylediğinde kullan."
---

# Web Tasarım ve UI

Tek dosyalık HTML/CSS/JS veya küçük bir frontend üretirken tasarım kalitesini ön planda tut. Amaç: şık, okunur, mobil-uyumlu, erişilebilir bir arayüz.

## Tasarım ilkeleri

- **Tasarım sistemi önce:** Bir renk paleti (1 ana + 1 vurgu + nötrler), tipografi (başlık/gövde için 2 yazı tipi, ölçek), boşluk ritmi (4/8px) ve yumuşak gölge/radius tanımla; her yerde tutarlı kullan.
- **Hiyerarşi:** Güçlü başlık, net okuma akışı, bol beyaz alan. Her ekranda tek belirgin odak.
- **Duyarlılık:** Mobile-first; CSS grid/flex; `clamp()` ile akışkan tipografi; kırılma noktaları. Yatay kaydırma bırakma.
- **Erişilebilirlik:** Yeterin kontrast (WCAG AA), semantik etiketler, `alt` metni, `:focus` görünürlüğü, klavye ile gezinme, `aria` etiketleri.
- **Karanlık/aydınlık:** `prefers-color-scheme` veya veri-öznitelikli tema; CSS değişkenleriyle.

## İş akışı

1. Kullanıcının amacı/marka/ifadeleri net değilse tek, kısa bir soru sor; sonra makul varsayılanlarla ilerle.
2. Önce iskeleti (layout + tasarım token'ları) kur, sonra içeriği doldur; tek seferde dev dosya yazmaya çalışma — iskelet `write`, eklemeler `edit`.
3. Ürettiğin dosyayı tarayıcıda/`php -S`/statik sunucuyla **gerçekten aç**; bozuk düzen, taşma, kontrast sorunu var mı bak.
4. Görsel gerekiyorsa yer tutucu veya kullanıcıya ait görsel kullan; telifsiz kaynak belirt.

## Kurallar

- Yerel tasarım diline ve kullanıcı isteğine uy; gereksiz süs/kütük ekleme.
- Doğrulama (açıp bakma) olmadan "tamamlandı" deme.
- Kullanıcının istediği değişiklikleri mevcut dosyaları okuyarak uygula; ilgisiz dosyaları değiştirme veya silme.
