# Qwen Image — üretim, düzenleme ve LoRA

[English](IMAGE.en.md) · [Modeller](MODELS.md)

Ana menüden 5 veya `./baslaticiler/baslat-qwen-image.sh` ile açın. Üç işlem vardır:

1. Yeni görsel: metin betimiyle üretim.
2. Düzenleme: kaynak görsel, isteğe bağlı maske ve değişiklik betimi. Eşleşen görsel projektörü gerekir. Korunması istenen kimlik/kadrajın kusursuz korunacağı garanti değildir.
3. Efekt: AI/model gerektirmeden FFmpeg ile 14 ayrı renk çıktısı. Kaynak fotoğraf değiştirilmez; bu yol için yalnız ffmpeg gerekir.

## Adımlar ve kalite

İşlem → kaynak (gerekiyorsa) → kanvas → kalite → stil → betim → efekt (düzenlemede) → seed → isteğe bağlı LoRA → özet/onay.

| Kanvas | Gerçek üretim | Son ölçek |
|---|---|---|
| Kare | 512×512 | 1080×1080 |
| Gönderi 4:5 | 512×640 | 1080×1350 |
| Hikâye 9:16 | 432×768 | 1080×1920 |
| Kaynak oranı (düzenleme) | Uzun kenar 640, kısa kenar 32'nin katı | Uzun kenar 1440 |

Ölçekleme yeni model ayrıntısı üretmez. Hızlı/dengeli/ayrıntılı seçenekleri 16/24/32 adımdır. CFG 6.0, Euler, VAE tiling 64×64 kullanılır. Düzenlemede VAE CPU'ya alınır; daha yavaş olabilir. Q4_K varsayılanı 16 GB bellek içindir. Üretim sırasında başka yerel model çalıştırmayın.

Sekiz stil: portre, ürün, yemek, manzara, mimari, giyimli moda, sinematik, minimal logo görünümü. Stil 0 kendi isteminizi kullanır. Logolar raster görüntüdür; vektör dosyası üretilmez.

14 efekt: Clarendon, Valencia, Gingham, Juno, Lark, sinematik, film/Portra, siyah-beyaz, VSCO A6/C1/M5, Kodak Ektar, altın saat, noir. Bunlar FFmpeg filtreleriyle benzetimdir; ilgili markaların özgün/lisanslı LUT paketleri değildir.

Seed boşsa rastgele (`-1`). Aynı seed, model ve ayarlar karşılaştırmayı kolaylaştırır; farklı motor/donanım sürümlerinde bit düzeyinde aynı sonuç garanti değildir. Çıktı: `$BOZKURT_WORKSPACE/Bozkurt-Gorseller`; teknik günlükler `gunlukler/`.

## Genel amaçlı LoRA ekleme

1. Qwen Image **2.1 mimarisiyle uyumlu** ve kullanım hakkına sahip olduğunuz bir stil/ürün/çizim adaptörü seçin; model kartını okuyun.
2. `.safetensors` dosyasını `modeller/model-arsivi/qwen-image-2.1/loras/` içine yerel olarak koyun. Basit dosya adları kullanın; dosyayı Git'e eklemeyin.
3. Görsel menüsünde LoRA seçin. Varsayılan kapalıdır; güç varsayılanı 0.8, aralık 0.1–1.5.
4. Önce 16 adım ve küçük kanvasla karşılaştırın. Hata varsa LoRA'yı kapatıp aynı isteği deneyin.

Başlık metadata'sı okunamayan veya NSFW/NCII işaretli adaptörler listeden çıkarılır. Bu metadata kontrolü bir içerik sınıflandırıcısı değildir ve tüm çıktıları garanti etmez. Bu dağıtım yetişkin ön ayarları, kişiye özel yüz betimleri veya bunları geri ekleme talimatı içermez. Genişletme rehberi genel amaçlı adaptörler içindir.
