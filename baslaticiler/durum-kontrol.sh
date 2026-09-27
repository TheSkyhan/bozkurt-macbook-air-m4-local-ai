#!/bin/zsh
source "${0:A:h}/../motorlar/lib/ortam.zsh"
# Bozkurt'un yalnızca yerel ve salt-okunur sağlık özeti.
set -u

PORT=8080
PI_BIN="/opt/homebrew/bin/pi"
LUCIFER_MODEL="$BOZKURT_ROOT/modeller/model-arsivi/lucifer-orcarouter-27b/orcarouter_Qwen3.8-27B-Uncensored-IQ2_M.gguf"
LUCIFER_CACHE="$BOZKURT_ROOT/modeller/model-arsivi/lucifer-orcarouter-27b/.cache/huggingface/download"

print "Bozkurt durum denetimi"
if [[ -x "$PI_BIN" ]]; then
  print "Pi: $($PI_BIN --version 2>/dev/null || print 'bilinmiyor')"
fi

LISTENER="$(lsof -ti TCP:$PORT -sTCP:LISTEN 2>/dev/null || true)"
if [[ -z "$LISTENER" ]]; then
  print "Model sunucusu: kapalı (bozkurt ile başlatılabilir)"
else
  STATUS="$(curl --silent --max-time 2 --output /dev/null --write-out '%{http_code}' http://127.0.0.1:$PORT/health 2>/dev/null || true)"
  if [[ "$STATUS" == "200" ]]; then
    MODEL="$(curl --silent --max-time 2 http://127.0.0.1:$PORT/v1/models 2>/dev/null | sed -n 's/.*\"id\":\"\([^\"]*\)\".*/\1/p' | head -n 1)"
    print "Model sunucusu: hazır${MODEL:+ — $MODEL}"
  elif [[ "$STATUS" == "503" ]]; then
    print "Model sunucusu: model yükleniyor"
  else
    print "Model sunucusu: dinliyor, sağlık yanıtı: ${STATUS:-ulaşılamadı}"
  fi
fi

print "Boş disk: $(df -h $HOME | awk 'NR==2 {print $4}')"

if [[ -s "$LUCIFER_MODEL" ]]; then
  print "Lucifer modeli: hazır ($(du -h "$LUCIFER_MODEL" | awk '{print $1}'))"
else
  PARTIAL="$(find "$LUCIFER_CACHE" -maxdepth 1 -name '*.incomplete' -type f -print -quit 2>/dev/null || true)"
  if pgrep -f '[h]f download.*orcarouter_Qwen3.8-27B-Uncensored-GGUF' >/dev/null 2>&1; then
    if [[ -n "$PARTIAL" ]]; then
      print "Lucifer modeli: indiriliyor ($(du -h "$PARTIAL" | awk '{print $1}') indirildi)"
    else
      print "Lucifer modeli: indiriliyor"
    fi
  elif [[ -n "$PARTIAL" ]]; then
    print "Lucifer modeli: indirme yarım/duraklatılmış ($(du -h "$PARTIAL" | awk '{print $1}'))"
  else
    print "Lucifer modeli: hazır değil"
  fi
fi

print "Bellek / swap: $(sysctl -n vm.swapusage 2>/dev/null || print erişilemiyor)"
print "Not: Ayrıntılı kurulum doğrulaması için bozkurt-test."
