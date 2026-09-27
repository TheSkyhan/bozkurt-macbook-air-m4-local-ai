#!/bin/zsh
source "${0:A:h}/../motorlar/lib/ortam.zsh"
# Genel sohbet ve özgür yazım: doğrulanmış Qwen 3.8 9B Distill Heretic Uncensored.
set -euo pipefail

ROOT="$BOZKURT_ROOT"
MODEL="$BOZKURT_ROOT/modeller/GGUF/Q8/Qwen3.8-9B-Distill-Heretic-GGUF/Qwen3.8-9B-Distill-Heretic-Uncensored-Q8_0.gguf"
BIN="${BOZKURT_LLAMA_BIN:-$(command -v llama-server)}"
HELPER="$ROOT/motorlar/lib/sunucu-yardimcisi.zsh"
TEMPERATURE="${BOZKURT_QWEN_TEMP:-0.75}"

if [[ ! -f "$MODEL" ]]; then
  print "Qwen genel sohbet modeli henüz indiriliyor. İndirme tamamlanınca tekrar deneyin."
  exit 1
fi

source "$HELPER"
bozkurt_sunucuyu_durdur

# 9B/Q8, 16 GB Air için güvenli kalite/bellek dengesidir. Bağlam 16K tutulur:
# Pi'nin karakter-tabanlı token tahmini Türkçe promptlarda şiştiği için 8K'da
# max_tokens=1'e inip modeli tek tokenla susturuyordu; 16K tahmine pay bırakır.
# Genel sohbette düşünme kapalıdır: kısa cevaplarda boş/uzun düşünme çıktısı oluşmaz.
# Aynı tercih Qwen'in gömülü Jinja şablonuna da açıkça aktarılır.
exec "$BIN" -m "$MODEL" --host 127.0.0.1 --port 8080 \
  -ngl 999 -fa on -c 16384 -np 1 --ctx-checkpoints 16 --checkpoint-min-step 256 --cache-ram 512 -ub 512 \
  --jinja --temp "$TEMPERATURE" --top-p 0.92 --top-k 40 \
  --chat-template-kwargs '{"enable_thinking":false}' \
  --reasoning off --reasoning-budget 0 --no-reasoning-preserve \
  --cors-origins localhost --no-cors-credentials
