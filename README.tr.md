# Bozkurt — MacBook Air M4 16GB için Localhost Yapay Zekâ

[English](README.en.md) · [Ana sayfa](README.md) · [Kurulum](docs/INSTALL.tr.md)

MacBook Air M4 üzerinde 16 GB birleşik bellekle yerel yapay zekâ çalıştırmak isteyenler için hazırlanmış terminal tabanlı bir sistemdir. Bozkurt; Bonsai, Qwen ve isteğe bağlı Lucifer metin profillerini, Qwen Image görsel üretimini, araştırma ve belge araçlarını tek menüde toplar. Çıkarım kendi Mac'inizde gerçekleşir; ücretli bulut LLM anahtarı gerekmez.

Bozkurt ayrı bir temel model değildir. Üçüncü taraf modelleri ve çıkarım motorlarını, Pi ajan arayüzü ve yerel araçlarla birleştirir. Model dosyaları ayrıca indirilir; yalnız kullanacağınız modları kurabilirsiniz.

## Kullanım

Kurulumdan sonra depo kökünde `./baslaticiler/bozkurt` çalıştırın. Enter varsayılan olarak 1'i seçer.

| Menü | Model / işlev | Araç kapsamı |
|---|---|---|
| 1 — Bozkurt Asistan | Bonsai 2 27B | Sohbet, salt okunur dosya inceleme, web, hava, hesap, PDF/belge |
| 2 — Lucifer Gizli Sohbet | OrcaRouter Qwen türevi 27B IQ2_M | Hesap ve yerel belge; web araçları yüklenmez |
| 3 — Genel Yardımcı | Qwen 9B Q8 yerel profili | Hızlı sohbet, salt okunur dosya araçları, web/hava, hesap, belge |
| 4 — Kodlama Ajanı | Bonsai 2 27B | Dosya yazma/düzenleme, terminal, araştırma ve temel macOS uygulama araçları |
| 5 — Qwen Image | Qwen Image 2.1 Q4_K | Görsel üretme, düzenleme ve renk efektleri |

“Gizli” adı geçmişi silmez. Oturumlar `.runtime/pi/` altında yerel olarak tutulur. Mod 1 ve 3 kod dosyalarını değiştirmez; kod için mod 4'ü seçin. Belge araçları bu sohbet modlarında çıktı oluşturabilir.

Örnek istekler:

- “Bu proje klasörünü incele; önce bulguları açıkla.”
- “7 kutuda 18'er kalem var, 23 dağıttım; kaç kaldı?”
- “Ankara'da yarın hava nasıl?”
- “Kaynak sayfalarını okuyarak bu konuda bir rapor oluştur.”
- Kod modunda: “Bu projedeki hatayı düzelt, uygun testi çalıştır ve sonucu bildir.”
- Görsel modunda: “Ahşap masada kırmızı seramik çaydanlık, yumuşak pencere ışığı.”

## Çalışma alanı ve komutlar

Varsayılan dosya çalışma alanı `~/Bozkurt-Workspace`, görseller onun içindeki `Bozkurt-Gorseller` klasörüdür. Farklı proje için:

```bash
BOZKURT_WORKSPACE="$HOME/Projects/ornek" ./baslaticiler/bozkurt
```

`/beceriler`, `/araclar`, `/eklentiler`, `/modeller`, `/komutlar` sistem bileşenlerini gösterir. `/otonomi` yüklü modlarda araç sayacını gösterir; istek başına sınır 80'dir. `/resume` önceki oturumları açar. Esc üretimi keser. Oturum kapansa da metin sunucusu açık kalabilir:

```bash
./baslaticiler/durum-kontrol.sh
./baslaticiler/durdur-ajan.sh
./baslaticiler/sistem-testi.sh
./yonet-beceriler.sh
```

## MacBook Air M4 / 16 GB yaklaşımı

Aynı anda tek model çalıştırın. Bonsai profili 24K bağlam ve q8_0 KV kullanır; Qwen 16K, Lucifer sunucusu 8K bağlam kullanır. Görsel üretim düşük çözünürlüklü kanvaslardan ölçeklenir. Büyük bağlam, ikinci model, çok sayıda tarayıcı sekmesi ve Q8 görsel çekirdeği bellek baskısını artırabilir. M4 Air fansızdır; uzun üretimlerde süre değişebilir. [Ayar rehberi](docs/SETTINGS.tr.md) değişkenleri ve sınırları açıklar.

## Ağ ve gizlilik

Metin API'si `127.0.0.1:8080` üzerindedir. Web araması sorguyu, sayfa okuma URL'yi, hava aracı şehri/koordinatı dış hizmetlere gönderir. Hava aracı kendiliğinden konum bulmaz; şehir belirtin veya kendi yerel ayarınızı girin. PDF gövdesindeki uzak görseller internet kullanabilir. Kod ajanında işletim sistemi sandbox'ı yoktur; dosya ve terminal yetkileri hesabınızla aynıdır.

Kişisel veriler, geçmiş, özel görev dosyaları, model ağırlıkları, özel yüz tanımları ve yetişkin görsel ön ayarları yayımlanmamıştır. Genel LoRA genişletmesi için [görsel rehberine](docs/IMAGE.tr.md) bakın.
