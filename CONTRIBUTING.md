# Katkı / Contributing

TR: Hata için mod, sürümler ve kısa yeniden üretim adımlarıyla issue açın. Kişisel verileri temizleyin. Değişiklikleri küçük tutun, iki dilde rehberleri güncelleyin, aşağıdaki kontrolleri çalıştırın. Model ağırlığı, oturum geçmişi, anahtar, kullanıcı çıktısı veya yetişkin ön ayarı eklemeyin.

EN: Report bugs with the mode, versions and minimal reproduction steps. Sanitize personal data. Keep changes focused, update both language guides and run the checks below. Do not add weights, history, credentials, user outputs or adult presets.

```bash
python3 tests/check_distribution.py
python3 -m unittest discover -s tests
```

TR: Bu kontroller model çıkarım kalitesini doğrulamaz. EN: These checks do not validate inference quality.
