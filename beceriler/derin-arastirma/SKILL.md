---
name: derin-arastirma
description: "Çok adımlı, kaynaklı derin web araştırması yap. Kullanıcı 'derinlemesine araştır', 'kapsamlı incele', 'kaynaklarıyla raporla', 'güncel ve doğru bilgi topla' gibi bir şey söylediğinde veya tek aramayla çözülmeyecek karmaşık bir soru geldiğinde kullan."
---

# Derin Web Araştırması

Basit bir soru değilse ve güvenilir, güncel, çok kaynaklı bir yanıt gerekiyorsa bu beceriyi uygula. Amaç: tek arama yerine planlı, çapraz doğrulamalı bir araştırma yürütüp sentezlenmiş bir sonuç üretmek.

## Yöntem (sırayla)

1. **Plan çıkar:** Konuyu 3-6 net alt soruya böl. Hangi bilgi parçalarının gerektiğini yaz.
2. **Çoklu arama:** Her alt soru için `web_arama` aracını AYRI bir sorguyla çağır (tek geniş sorgu değil, daraltılmış çoklu sorgular). Farklı terim/sinonim dene.
3. **Kaynak seç ve oku:** Sonuçlardaki uygun URL’leri `web_oku` ile aç; gerçek sayfa metnini oku. Güvenilir kaynakları tercih et (resmî site, birincil doküman, ansiklopedi, akademik). Şüpheli/blog tek kaynağa güvenme.
4. **Çapraz doğrula:** Önemli her iddiayı en az iki bağımsız kaynakla teyit et. Kaynaklar çelişirse çelişkiyi açıkça belirt ve hangisinin güçlü olduğunu gerekçelendir.
5. **Tarih/tazelik kontrolü:** Bilginin ne zamana ait olduğunu belirt; "güncel" istendiyse en yeni kaynağı öne al.
6. **Sentezle:** Bulguları kendi cümlelerinle, başlıklar/alt başlıklarla topla. Ham sonuç listesini aynen yapıştırma.

## Çıktı biçimi

- Kısa bir **yönetici özeti** (2-4 cümle), sonra bölümler hâlinde detay.
- Her temel iddianın yanında **kaynak** (başlık + URL). Kaynak listesi sonda toplanabilir.
- Emin olmadığın/çelişkili noktaları "Belirsizlik:" diye ayrı işaretle.
- Kullanıcı belge isterse sonucu `pdf_uret` ile A4 rapor/PDF'e çevir (gövdede `[görsel: anahtar kelime]` ile alakalı görsel eklenebilir).

## Kurallar

- Araç sonucu olmadan güncel bilgi, sayı, tarih veya alıntı UYDURMA. Bulamazsan "bulunamadı" de.
- Arama aracı sonuç döndürmezse (ağ/motor engeli) bunu saklama; kullanıcıya araştırmanın kısmen yapılabildiğini söyle.
- Kaynak URL'lerini olduğu gibi, bozmadan ver.
