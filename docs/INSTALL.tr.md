# MacBook Air M4 16GB — Kurulum

[Tanıtım](../README.tr.md) · [English](INSTALL.en.md)

Bu dağıtım macOS Apple Silicon ve zsh içindir. Windows/Linux veya Intel Mac desteği doğrulanmadı. Homebrew ve Xcode Command Line Tools kurulu olmalı (`xcode-select --install`). Model indirmeleri için internet ve yeterli boş disk gerekir; yalnız çekirdek Bonsai kurulumu bile birkaç GB model ve motor indirir. Tüm modelleri aynı anda indirmeniz gerekmez.

## 1. Araçları kurun

```bash
brew install node python llama.cpp ffmpeg cmake pango cairo libffi
npm install -g @earendil-works/pi-coding-agent@0.87.1
git clone https://github.com/TheSkyhan/bozkurt-macbook-air-m4-local-ai.git
cd bozkurt-macbook-air-m4-local-ai
./kurulum.sh
```

Homebrew/npm kendi paketlerini internetten indirir. Kurulum betiği mevcut `~/.pi/agent` ayarlarını değiştirmez; `.runtime/pi` içinde ayrı model ve ayar dosyaları oluşturur. Yeniden çalıştırmak mevcut dosyaları ezmez.

## 2. Bonsai ile başlayın

Aşağıdaki sabit sürüm, referans kurulumda kullanılan kaynak sürümüdür. Model lisansını ve upstream kurulumunu inceleyin.

```bash
git clone https://github.com/PrismML-Eng/Bonsai-demo.git motorlar/Bonsai-demo
git -C motorlar/Bonsai-demo checkout 17b143e889a45c090816b520e79a50c996164e1f
(cd motorlar/Bonsai-demo && BONSAI_OPENWEBUI=0 BONSAI_CODE_INTERPRETER=0 ./setup.sh)
./baslaticiler/bozkurt
```

Menüde **1** sohbet/araştırma veya **4** kodlama seçin. Bonsai kendi uyumlu llama.cpp motoruna ihtiyaç duyar; Homebrew motorunu Bonsai dosyasına yönlendirmeyin. Diğer modelleri [model rehberinden](MODELS.md) kurun.

## 3. PDF desteği

```bash
python3 -m venv .venv-pdf
.venv-pdf/bin/python -m pip install -r requirements-pdf.txt
```

WeasyPrint ilk tercihtir; araç ayrıca kurulu Chrome/Chromium/Edge veya sistem PDF yedeğini deneyebilir. Çıktı kalitesi motorlar arasında değişir.

## 4. İsteğe bağlı kısa komut

Depo kökündeyken aşağıdaki komutla bu Terminal için takma ad oluşturun. Kalıcı kullanmak isterseniz oluşan satırı kendi `~/.zshrc` dosyanıza ekleyin.

```zsh
alias bozkurt="${(q)PWD}/baslaticiler/bozkurt"
```

## 5. Kontrol

`python3 tests/check_distribution.py` kaynak paketini denetler. `python3 -m unittest discover -s tests` model indirmeden regresyon testlerini çalıştırır. `./baslaticiler/sistem-testi.sh` tam yerel kurulumu denetler; kurmadığınız isteğe bağlı motorları eksik gösterebilir. Sağlık URL'si `http://127.0.0.1:8080/health`, API kökü `http://127.0.0.1:8080/v1`.

Güncellemeden önce yerel ayarları ayrı yedekleyin. `.runtime/pi` içindeki eski ayarlar yeni örneklerden otomatik değiştirilmez. Kaynak paketini kaldırmak, başka konumdaki `~/Bozkurt-Workspace` çıktılarını kaldırmaz.
