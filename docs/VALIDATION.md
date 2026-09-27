# Validation / Doğrulama

Publication preparation: 2026-09-27.

## Türkçe

Bu yayın için kaynak sözdizimi/bağlantı kontrolleri, aritmetik ve belge yolu sınırları, açık konum gereksinimi, boşluklu dizinde taşınabilir kurulum, mevcut ayarların korunması, model olmadan 14 gerçek FFmpeg efekti ve sahte motorla görsel menü/çıktı/LoRA eleme akışı denetlenir. Sahte motor testi görsel kalitesini ölçmez.

Beş TypeScript eklentisi kurulu Pi 0.87.1 yükleyicisiyle yüklendi; araştırma eklentisinin gerçek `hesapla` yürütmesi `18*7-23 = 103` döndürdü.

Yeni bir Mac üzerinde sıfırdan tüm model indirmeleri, tam metin çıkarım matrisi, tam çözünürlüklü görsel düzenleme ve PDF görsel düzen doğrulaması bu dağıtım için tekrar yapılmadı. Önceki yerel kurulumun ölçümleri bu yeni paket için hız garantisi olarak sunulmaz. CI modeller indirmez veya çalıştırmaz; FFmpeg mevcut değilse efekt testi atlanır.

## English

Publication checks cover source syntax/links, arithmetic and document path boundaries, explicit location requirements, portable configuration in paths with spaces, preservation of existing settings, fourteen real FFmpeg effects without models, and image menu/output/LoRA filtering using a stub engine. Stub tests do not measure image quality.

All five TypeScript extensions loaded with the installed Pi 0.87.1 loader. The research extension's actual `hesapla` execution returned `18*7-23 = 103`.

Fresh model downloads on a new Mac, the full text-inference matrix, full-resolution image editing and visual PDF layout validation were not repeated for this distribution. Earlier local measurements are not presented as speed guarantees for this package. CI does not download/run models; the effects test skips when FFmpeg is unavailable.

```bash
python3 tests/check_distribution.py
python3 -m unittest discover -s tests -v
```
