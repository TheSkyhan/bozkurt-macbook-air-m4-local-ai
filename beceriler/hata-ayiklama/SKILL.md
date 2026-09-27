---
name: hata-ayiklama
description: "Bir hatayı/yanlış davranışı sistematik olarak ayıkla ve kök nedene in. Kullanıcı 'hata var', 'çalışmıyor', 'hata ayıkla/debug', 'beklenmeyen sonuç', 'crash' dediğinde kullan."
---
# Hata Ayıklama (Debugging)

Rastgele düzeltme yapma; kanıtla ilerle. Amaç: semptomu değil kök nedeni bulmak.

## Yöntem (sırayla)
1. **Yeniden üret:** Hatanın kesin komutunu/girdisini al ve tekrar tetikle. Üretemiyorsan önce üretilebilir hale getir.
2. **Tam hatayı oku:** Traceback'in TAMAMINI, satır/sütun ve hata türünü oku; son satır genellikle sonuçtur, asıl neden üstte.
3. **Daralt:** Kodu ikiye böl / print-log / debugger ile hatanın oluştuğu en küçük aralığı bul. "Çalışan" ile "çalışmayan" arasındaki farkı netleştir.
4. **Kök neden hipotezi:** Gözleme dayalı tek bir hipotez kur; en basit açıklamayı dene (son değişiklik, sınır durum, tip/None, yol/izin, kodlama, yarış).
5. **Minimum düzelt + doğrula:** Yalnız kök nedeni hedefleyen en küçük değişikliği yap; hatayı yeniden üretmeye çalış — artık çıkmıyorsa düzeldi. Test ekle ki geri gelmesin.
6. **Yan etkileri kontrol et:** Aynı fonksiyonu/dosyayı kullanan yerleri ve test suite'ini çalıştır.

## Kurallar
- Varsayımları "kanıt" ile doğrula; "muhtemelen şudur" diye toplu düzeltme yapma.
- Bağımlılık/önbellek dizinlerine (node_modules, .venv, site-packages, __pycache__) dokunma.
- Aynı hatayı 3 kez denediysen hâlâ geçmiyorsa dur, bulguları özetle ve kullanıcıya strateji sor.
- Düzeltmeyi AJAN_HAFIZA.md'de kısa not et (neden + çözüm).
