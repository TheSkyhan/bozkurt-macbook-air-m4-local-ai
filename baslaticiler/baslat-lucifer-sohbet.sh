#!/bin/zsh
source "${0:A:h}/../motorlar/lib/ortam.zsh"
# Lucifer Sohbet: OrcaRouter Qwen 3.8 27B Uncensored, 16 GB Air için dar bellek profili.
set -euo pipefail

ROOT="$BOZKURT_ROOT"
MODEL="$ROOT/modeller/model-arsivi/lucifer-orcarouter-27b/orcarouter_Qwen3.8-27B-Uncensored-IQ2_M.gguf"
BIN="${BOZKURT_LLAMA_BIN:-$(command -v llama-server)}"
HELPER="$ROOT/motorlar/lib/sunucu-yardimcisi.zsh"

if [[ ! -s "$MODEL" ]]; then
  print "Lucifer Sohbet modeli indiriliyor veya henüz hazır değil. Durumu görmek için: bozkurt-durum"
  exit 1
fi

source "$HELPER"
bozkurt_sunucuyu_durdur

# 27B/IQ2_M + 8K Q8 KV: 16 GB Air'de Metal OOM'suz sınır. Pi'nin karakter-tabanlı
# token tahmini Türkçe promptlarda şişer; models.json'da contextWindow 16384
# tutulur (Pi görünümü), sunucu gerçekte 8K'da kalır. Gerçek promptlar küçüktür.
exec "$BIN" -m "$MODEL" --host 127.0.0.1 --port 8080 \
  -ngl 999 -fa on -c 8192 -np 1 --ctx-checkpoints 16 --checkpoint-min-step 256 --cache-ram 512 -ub 256 -ctk q8_0 -ctv q8_0 \
  --jinja --temp 0.90 --top-p 0.95 --top-k 60 \
  --reasoning off --reasoning-budget 0 --no-reasoning-preserve \
  --cors-origins localhost --no-cors-credentials
