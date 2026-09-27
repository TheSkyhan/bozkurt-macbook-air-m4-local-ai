#!/bin/zsh
source "${0:A:h}/../motorlar/lib/ortam.zsh"
# "Gizli mod" ayrı bir mod değildir: Pi oturum geçmişleri diske kaydedilir ve
# yerel modellerde tarayıcı tarzı gizli oturum bulunmaz. Kullanıcıyı yanıltmamak
# için bu başlatıcı durumu açıklar ve normal menüye yönlendirir.
print "Not: Bozkurt'ta ayrı bir gizli mod yoktur; Pi oturum geçmişleri diske kaydedilir."
print "Her mod seçimi yeni ve bağımsız bir sohbet başlatır. Ana menü açılıyor…"
sleep 2
exec "$(dirname "$0")/baslat-asistan.sh"
