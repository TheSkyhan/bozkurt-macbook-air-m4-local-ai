# Ayarlar — M4 / 16 GB

[English](SETTINGS.en.md) · [Ana sayfa](../README.tr.md)

## Dosyalar

- `yapilandirma/models.example.json`: dağıtılan sağlayıcı örnekleri; tamamı `127.0.0.1:8080/v1` kullanır. `yerel` gerçek bir anahtar değil, yerel istemci yer tutucusudur.
- `.runtime/pi/models.json`: ilk açılışta örnekten oluşturulan etkin sağlayıcılar. `contextWindow` istemcinin bağlam hesabı, `maxTokens` yanıt üst sınırıdır.
- `.runtime/pi/settings.json`: otomatik özetleme, tema, yakın geçmiş ve mod başına token rezervleri.
- `yapilandirma/etkin-beceriler.conf`: `1` açık, `0` kapalı. `./yonet-beceriler.sh` menüsü bu dosyayı düzenler. Yeni beceri için `beceriler/<ad>/SKILL.md` oluşturup listeye ekleyin.
- `yapilandirma/konum.conf`: isteğe bağlı kişisel konum; Git tarafından dışlanır. Şehir adını her istekte belirtmek yeterlidir.

## Ortam değişkenleri

| Değişken | Varsayılan / işlev |
|---|---|
| `BOZKURT_ROOT` | Otomatik depo kökü; genellikle değiştirmeyin |
| `BOZKURT_WORKSPACE` | `~/Bozkurt-Workspace`; çıktı ve ajan çalışma alanı |
| `PI_CODING_AGENT_DIR` | `$BOZKURT_ROOT/.runtime/pi`; ayarlar ve oturumlar |
| `BOZKURT_LLAMA_BIN` | PATH içindeki `llama-server`; Qwen/Lucifer motoru |
| `BOZKURT_QWEN_TEMP` | `0.75`; yüksek değer daha değişken yanıt |
| `BONSAI_CTX` | `24576`; Bonsai sunucu bağlamı |
| `BONSAI_REASONING_BUDGET` | `384`; `0` düşünme kanalını kapatır |
| `BOZKURT_WEB_OKU_SINIR` | Web sayfası karakter sınırı; eklenti varsayılanı 14000, menü modları daha düşük değer verebilir |
| `BOZKURT_WEB_DISABLED` | Menü 2'de `1`; belge aracında uzak kaynak kontrolü |
| `BOZKURT_KONUM_LAT`, `BOZKURT_KONUM_LON`, `BOZKURT_KONUM_SEHIR` | Yalnız sizin gireceğiniz isteğe bağlı konum |

## Çıkarım profilleri

| Profil | Sunucu bağlamı | KV | Önbellek / checkpoint | Örnekleme |
|---|---:|---|---|---|
| Bonsai | 24576 | q8_0 K/V | 4096 MiB / 128, aralık 128 | upstream Bonsai 2 profili; düşünme bütçesi 384 |
| Qwen | 16384 | motor varsayılanı | 512 MiB / 16, aralık 256 | sıcaklık .75, top-p .92, top-k 40 |
| Lucifer | 8192 | q8_0 K/V | 512 MiB / 16, aralık 256 | sıcaklık .90, top-p .95, top-k 60 |

Lucifer istemci örneği 16384 gösterirken sunucu 8192 kullanır; bu mevcut kurulumdan gelen Türkçe token tahmini uyarlamasıdır, gerçek 16K destek değildir. Uzun istemler taşabilir. Sorunda istemci bağlamını 8192 ile eşitleyin ve özetleme payını koruyun. Bonsai bağlamını düşürürseniz istemci `contextWindow` değerini de eşitleyin.

```bash
BONSAI_CTX=16384 ./baslaticiler/bozkurt
```

Bonsai çıkarım ayarları kaynak kurulumdan korunmuştur; daha hızlı çalışma garantisi verilmez. `BOZKURT_EARLY_COMPACT_AT` eski başlatıcılarda bulunur ama güncel eklenti bu değişkeni kullanmaz; otomatik özetleme Pi ayarlarından yönetilir.

## Headless kod ajanı

Önce `./baslaticiler/baslat-bonsai.sh` ile sunucuyu ayrı Terminal'de başlatın. Sonra:

```bash
BOZKURT_PROJE="$HOME/Projects/ornek" \
BOZKURT_GOREV="Testleri çalıştır ve hatanın nedenini raporla." \
./baslaticiler/baslat-headless-ajan.sh
```

`BOZKURT_GOREV_DOSYA` görev dosyası, `BOZKURT_SID` devam oturumu, `BOZKURT_MODEL` sağlayıcı/model, `BOZKURT_MAX_TUR` varsayılan 8, `BOZKURT_DUSUNME` varsayılan off, `BOZKURT_ARACLAR` araç seçenekleridir. `BOZKURT_EKLENTISIZ=1` otonomi eklentisini kaldırır; tekrar koruması da kalkar. Başarı için sıfır çıkış kodu ve son satırda tam `GOREV_TAMAM` gerekir. Görev günlükleri özel veri içerebilir; paylaşmayın.
