---
name: makale-pdf
description: Sayfa hedefli Türkçe makale veya raporu bölüm bölüm oluşturup PDF olarak doğrula.
---
# Makale ve PDF
- Önce belge türünü ayırt et: kullanıcının metnini dönüştürme, kurgu, genel açıklama veya kaynaklı araştırma. Kullanıcının metni ve kurgu için zorunlu web araması yapma.
- Kaynaklı/güncel araştırmada `web_arama` ardından `web_oku` kullan. Başlık veya arama snippet'inden alıntı üretme. Gerçek okunan kaynakları sonda belirt; doğrulanamayan bilgiyi açıkça ayır.
- Uzun metni `belge_yaz` ile bölüm bölüm biriktir. İlk çağrıda sifirla=true yalnız yeni/yeniden üretilmesi istenen belge için kullan. Sonraki çağrılarda false kullan.
- İlk taslak bütçesi sayfa başına yaklaşık 400–600 kelimedir; gerçek sayfa sayısını `pdf_uret` sonucundan öğren. Kullanıcı görsel isterse uygun [görsel: konu] kullan; çevrimdışı modda uzak görsel isteme.
- `pdf_uret` aracına gövdeyi govde_dosya ile ver. Hedefe uymuyorsa en fazla iki içerik düzeltmesi yap; okunabilirliği bozmak için metni şişirme veya küçültme.
- Araç başarı sonucu dönmeden kaydedildi deme. Çıktı yolunu ve gerçek sayfa sayısını bildir. Görsel inceleme aracı varsa taşma, kesilme ve Türkçe karakterleri kontrol et; yoksa bu kontrolün yapılmadığını söyle.
