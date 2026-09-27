#!/bin/zsh
source "${0:A:h}/motorlar/lib/ortam.zsh"
# Yerel becerileri aç/kapat: model bağlamına yalnızca seçilen becerilerin kısa tanımı gelir.
set -euo pipefail
ROOT="$BOZKURT_ROOT"
AYAR="$ROOT/yapilandirma/etkin-beceriler.conf"

# Beceri listesini conf'tan dinamik oku; yeni beceriler otomatik görünür.
typeset -a ADS
ADS=()
while IFS='=' read -r AD DURUM_OKU; do
  [[ "$AD" == \#* || -z "$AD" ]] && continue
  ADS+=("$AD")
done < "$AYAR"
TOPLAM=${#ADS[@]}

while true; do
  clear
  print "Yerel Asistan — Beceri Yönetimi"
  print "Beceriler görev gerektiğinde açılır; tüm metinleri sürekli bağlamda tutulmaz."
  integer I=1
  for AD in $ADS; do
    DURUM=$(awk -F= -v ad="$AD" '$1==ad {print $2}' "$AYAR")
    [[ "$DURUM" == "1" ]] && ETIKET="Açık" || ETIKET="Kapalı"
    print "$I) $AD — $ETIKET"
    ((I++))
  done
  print "0) Çıkış"
  printf "Aç/kapatmak için numara (0-%d): " "$TOPLAM"
  read SECIM
  [[ "$SECIM" == "0" ]] && exit 0
  if [[ "$SECIM" =~ ^[0-9]+$ ]] && (( SECIM >= 1 && SECIM <= TOPLAM )); then
    AD=${ADS[$SECIM]}
    DURUM=$(awk -F= -v ad="$AD" '$1==ad {print $2}' "$AYAR")
    YENI=1; [[ "$DURUM" == "1" ]] && YENI=0
    sed -i '' "s/^${AD}=.*/${AD}=${YENI}/" "$AYAR"
  else
    print -u2 "Geçersiz seçim: $SECIM"
    sleep 1
  fi
done
