#!/bin/zsh
source "${0:A:h}/../motorlar/lib/ortam.zsh"
set -euo pipefail

source "$BOZKURT_ROOT/motorlar/lib/sunucu-yardimcisi.zsh"
if ! lsof -ti TCP:8080 -sTCP:LISTEN >/dev/null 2>&1; then
  print "Çalışan yerel ajan bulunamadı."
  exit 0
fi
bozkurt_sunucuyu_durdur
print "Yerel ajan durduruldu."
