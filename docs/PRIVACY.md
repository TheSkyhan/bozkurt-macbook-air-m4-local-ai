# Gizlilik / Privacy

## Türkçe

Bu depo seçilmiş kaynak dosyalarından oluşturulmuştur; mevcut kurulumun veya eski Git geçmişinin toplu kopyası değildir. Yalnız kaynak kodu, temalar, beceriler, boş/örnek ayarlar, rehberler ve testler yayımlanır.

Dışlananlar: konuşmalar, oturumlar, kimlik bilgileri, API anahtarları, kişisel ad/yol/konum kayıtları, proje hafızası, özel görev dosyaları, günlükler, yedekler, fotoğraf/PDF çıktıları, model/LoRA ağırlıkları, derlenmiş motorlar ve sanal ortamlar. Qwen Image'ın özel yüz tanımı, yetişkin ön ayarları ve ilgili menü yolu çıkarılmıştır. Depo sahibi olarak yalnız GitHub hesabının herkese açık kimliği kullanılır.

Çalıştırınca `.runtime/pi`, `gunlukler` ve seçtiğiniz çalışma alanında yeni özel veriler oluşabilir. `.gitignore` bunları dışlar; `git add -f` bu korumayı aşar. Paylaşmadan önce staged dosyaları inceleyin. GitHub kullanıcı adınız ve commit zamanı yayının doğal metadata'sıdır.

Model çıkarımı yereldir; web, hava ve uzaktaki belge görselleri dış hizmetlere bağlanabilir. Başlatıcılar bir ağ güvenlik duvarı değildir. Kod ajanı kullanıcının yetkileriyle komut çalıştırır. “Gizli” mod sohbet geçmişini şifrelemez veya silmez. Model çıktıları yanlış olabilir.

## English

This repository was assembled from selected source files, not copied wholesale from a live installation or old Git history. It contains source code, themes, skills, empty/example settings, guides and tests.

Excluded: chats, sessions, credentials, API keys, personal name/path/location records, project memory, private task files, logs, backups, photos/PDF outputs, model/LoRA weights, compiled engines and virtual environments. Qwen Image's private face description, adult presets and related menu path were removed. Only the account's public GitHub identity is used for repository ownership.

Running the software creates new private data under `.runtime/pi`, `gunlukler` and your workspace. `.gitignore` excludes these, but `git add -f` bypasses it. Review staged files before sharing. Your GitHub username and commit timestamp are normal publication metadata.

Inference is local; web, weather and remote document images may contact external services. Launchers are not a network firewall. The coding agent runs commands with your account's permissions. “Gizli” mode does not encrypt or erase history. Model outputs may be incorrect.
