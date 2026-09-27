---
name: veri-analizi
description: "CSV/JSON/Excel gibi veriyi Python ile analiz et, özetle ve grafik/rapor üret. Kullanıcı 'bu veriyi analiz et', 'grafik çıkar', 'istatistik', 'CSV'ye bak', 'raporla' dediğinde kullan."
---
# Veri Analizi

Veriyi önce tanı, sonra analiz et. Python (pandas/matplotlib varsa) veya stdlib ile çalıştırılıp doğrulanan sonuç üret.

## Akış
1. **Keşfet:** Dosyayı oku; sütunlar, tipler, satır sayısı, eksikler, kodlama (UTF-8?), ayraç. `head`, `dtypes`, `describe`, null sayıları.
2. **Temizle:** Tarih/sayı tiplerini düzelt, gereksiz boşluk/birimi ayıkla, tekrarları kontrol et. Silme yerine filtre; kullanıcıya ne attığını söyle.
3. **Analiz:** Soruya göre grupla/ölç (toplam, ort, medyan, dağılım, korelasyon, trend, aykırı değer). Kümülatif/yıllık karşılaştırma gerekiyorsa öyle yap.
4. **Görselleştir:** matplotlib varsa grafiği PNG olarak kaydet (başlık/eksen/birim etiketli). Yoksa ASCII/özet tablo + `pdf_uret` ile rapor.
5. **Raporla:** Bulguları sade Türkçe ile; sayıları kaynak veriye bağla. İstenirse `pdf_uret` ile A4 rapor yap (görselleri `![...](dosya.png)` ile ekle).

## Kurallar
- Bağımlılık yoksa önce mevcut olanı kontrol et (`python3 -c "import pandas"`); yoksa stdlib (csv, statistics) ile yap veya kullanıcıya sor.
- Büyük dosyayı belleğe komple alma; parça/iteratif oku.
- Sonucu uydurma — çalışan kodun ürettiği sayıyı raporla. Grafikleri masaüstüne/proje klasörüne kaydet, yolunu ver.
