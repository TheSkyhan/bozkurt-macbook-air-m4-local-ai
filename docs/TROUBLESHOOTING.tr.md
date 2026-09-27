# Sorun giderme

| Belirti | Kontrol / çözüm |
|---|---|
| `pi` bulunamadı | Kurulum rehberindeki npm komutunu çalıştırın; `command -v pi` ile PATH'i kontrol edin. |
| Model dosyası yok | Yalnız kullandığınız modun modelini kurun; `docs/MODELS.md` yoluyla başlatıcıdaki yolu karşılaştırın. |
| 8080 meşgul | `lsof -nP -iTCP:8080 -sTCP:LISTEN`. Başlatıcı başka uygulamanın sürecini kapatmayı reddeder. O uygulamayı kendiniz durdurun. |
| Sunucu erken kapandı / 3 dakika geçti | `gunlukler/` içindeki ilgili sunucu günlüğünü yerel olarak inceleyin; eksik ağırlık, uyumsuz bayrak veya bellek hatasına bakın. |
| Metal OOM / yüksek swap | Diğer ağır uygulamaları kapatın; tek model kullanın; Qwen Image Q4_K ve küçük kanvas seçin. Bonsai bağlamını azaltırsanız istemci ayarını da eşitleyin. |
| `unknown argument` | Çıkarım motoru sürümünü referans sürümle karşılaştırın; güncel Homebrew sürümü aynı bayrakları desteklemeyebilir. |
| Görsel düzenleme başarısız | Qwen 2.1 VAE, Qwen3-VL kodlayıcı ve eşleşen projektörü kontrol edin. Yalnız metinden görselde projektör zorunlu değildir. |
| LoRA listede yok | Dosya uzantısı, dizin, metadata ve 2.1 uyumluluğunu kontrol edin. İşaretli veya bozuk metadata kabul edilmez. |
| Hava konum hatası | Şehir adını açıkça yazın. Otomatik GPS/IP keşfi yoktur. |
| PDF kötü / oluşturulamadı | `.venv-pdf` ve WeasyPrint kurulumu ile Homebrew pango/cairo bağımlılıklarını kontrol edin. Uzaktaki görseller için ağ gerekir. |
| Uygulama pencere bilgisi yok | macOS Sistem Ayarları → Gizlilik ve Güvenlik → Otomasyon/Erişilebilirlik izinlerini kontrol edin. İzin atlatılmaz. |
| Yanıt boş / çok uzun | Modelin gerçek bağlamı, istemci bağlamı, yanıt payı ve düşünme bütçesini kontrol edin; yeni kısa oturum deneyin. |

Tam GUI tıklama/tarayıcı otomasyonu dahil değildir. `/resume` yalnız bu kurulumun Pi dizinindeki oturumları gösterir. `sistem-testi.sh` tam kurulum denetimidir; isteğe bağlı motor eksikliği çekirdek Bonsai kullanımını tek başına engellemez.

Hata bildirirken sürüm, mod, tekrarlama adımları ve kişisel verileri çıkarılmış kısa hata metni verin. Tüm günlük veya konuşma geçmişini yüklemeyin.
